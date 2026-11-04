%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MATLAB design: Binarized Neural Network (BNN) Digit Recongnition
% 
% Introduction:
% A simple BNN with 2 conv layers and 2 fully-connected layer, both input 
% feature map and weights are binarized.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This example defines the streaming port in an explicit method.
% i.e., divide the input image into packets according to the configured 
% bus bandwidth. Then, in the design file, re-assemble these packets 
% to recreate the original image.
% 

%   Copyright 2023 The MathWorks, Inc.
%#codegen
function predict_number = mlhdlc_bnn(image_piece)
% [Placeholder] Uncomment for interface optimization before release
% coder.hdl.interface('image_piece','AXI4-Stream');
% coder.hdl.interface('predict_number','AXI4-Stream');

  % re-defined macros: 1
  PIXELS_PER_IMAGE = 256; % I_WIDHT1 * I_WIDHT1
  BUS_WIDTH = 32;

  % layer configuration
  % manually pass them into the subfunctions to avoid re-defination
  I_WIDHT1        = 16; % width of conv1 input feature map
  NUM_CHANNEL1    = 16; % number of conv1 output channels
  I_WIDTH2        = 8;  % width of conv2 input feature map
  NUM_CHANNEL2    = 32; % number of conv2 output channels
  O_WIDTH         = 4;  % conv2 output width
  F_WIDTH         = 3;  % filter width
  F_SIZE          = F_WIDTH*F_WIDTH; 
  PADDING         = F_WIDTH-1;
  MAX_FMAP        = 4096; % 18*18*16
  NUM_FC1_IN      = O_WIDTH*O_WIDTH*NUM_CHANNEL2;
  NUM_FC2_IN      = 256;
  NUM_FC2_OUT     = 10;
  STRIDE_MAX_POOL = 2;

  % local buffer
  persistent image;
  persistent image_piece_counter;
  % reuse the buffer in all layers
  % if apply the task-level pipelining (Vitis HLS dataflow), then we should instantiate
  % distinct buffers for each stage.
  fmap_buf_1 = coder.nullcopy(zeros(1,int32(MAX_FMAP)));
  fmap_buf_2 = coder.nullcopy(zeros(1,int32(MAX_FMAP)));

  % initialize the persistent variable
  if isempty(image)
    image = coder.nullcopy(zeros(1,int32(PIXELS_PER_IMAGE)));
    image_piece_counter = 0;
  end

  % fetch and re-assemble image
  image_idx_prefix = image_piece_counter * BUS_WIDTH;
  image_piece_counter = image_piece_counter + 1;

  %image(((image_piece_counter-1)*BUS_WIDTH+1):image_piece_counter*BUS_WIDTH) = image_piece;
  coder.hdl.loopspec('pipeline');
  for i=1:BUS_WIDTH
    image(image_idx_prefix+i) = image_piece(i);
  end

  
  % load the threshold
  threshold1_input = coder.load('threshold1_input.mat');
  threshold1       = threshold1_input.data;
  threshold2_input = coder.load('threshold2_input.mat');
  threshold2       = threshold2_input.data;
  
  predict_number = -1;
  if image_piece_counter == PIXELS_PER_IMAGE/BUS_WIDTH
    % received one complete image, start prediction
    % first conv layer %
    fmap_buf_1 = pad(image, 1, I_WIDHT1, PADDING, MAX_FMAP);
    fmap_buf_2 = conv_layer_1(fmap_buf_1, threshold1, 1, NUM_CHANNEL1, I_WIDHT1+PADDING, F_WIDTH, F_SIZE, PADDING, MAX_FMAP);
    fmap_buf_1 = max_pool(fmap_buf_2, NUM_CHANNEL1, I_WIDHT1, MAX_FMAP, STRIDE_MAX_POOL);
    
    % second conv layer %
    fmap_buf_2 = pad(fmap_buf_1, NUM_CHANNEL1, I_WIDTH2, PADDING, MAX_FMAP);
    fmap_buf_1 = conv_layer_2(fmap_buf_2, threshold2, NUM_CHANNEL1, NUM_CHANNEL2, I_WIDTH2+PADDING, F_WIDTH, F_SIZE, PADDING, MAX_FMAP);
    fmap_buf_2 = max_pool(fmap_buf_1, NUM_CHANNEL2, I_WIDTH2, MAX_FMAP, STRIDE_MAX_POOL);

    fmap_buf_1 = reshape_local(fmap_buf_2, NUM_CHANNEL2, O_WIDTH, MAX_FMAP);
    
    % fully-connected layers
    fmap_buf_2 = fully_connect_1(fmap_buf_1, NUM_FC1_IN, NUM_FC2_IN, MAX_FMAP);
    fmap_buf_1 = fully_connect_2(fmap_buf_2, NUM_FC2_IN, NUM_FC2_OUT, MAX_FMAP);
     
    % find predicted digit
    for i = 1:NUM_FC2_OUT
      if (fmap_buf_1(i))
        predict_number = i-1;
      end
    end
    image_piece_counter = 0;
  else
    predict_number = -1;
  end
end

%% subfunctions
% padding
%   Input:  fmap_in  - input feature maps
%           M        - number of input feature maps
%           I        - width of input feature maps
%   Output: fmap_out - padded feature maps
function fmap_out = pad(fmap_in, M, I, PADDING, MAX_FMAP)
  fmap_out = coder.nullcopy(zeros(1,int32(MAX_FMAP)));
  % calculate the size of feature map
  sz_fmap_in  = I * I;
  sz_fmap_out = (I+PADDING) * (I+PADDING);

  coder.hdl.loopspec('pipeline');
  % initialize the output buffer
  %fmap_out = zeros(1,MAX_FMAP);
  for i = 1:MAX_FMAP
    fmap_out(i) = 0;
  end

  % write the output feature map
  for m = 1:M
    coder.hdl.loopspec('pipeline');
    for x = 1:I
      for y = 1:I
        i_idx = x+(y-1)*I+(m-1)*sz_fmap_in;
        o_idx = (x+PADDING/2)+(y-1+PADDING/2)*(I+PADDING)+(m-1)*sz_fmap_out;
        fmap_out(o_idx) = fmap_in(i_idx);
      end
    end
  end
end


% convolution layer 1
%  Input:  fmap_in   - input feature map
%          threshold - threshold for batchnorm operation
%          M         - number of input feature map
%          N         - number of output feature map
%          I         - width of input feature map
%  Output: fmap_out  - output feature map
%
% Optimization: window buffer and line buffer
function fmap_out = conv_layer_1(fmap_in, threshold, M, N, I, F, F_SIZE, PADDING,MAX_FMAP)
  fmap_out = coder.nullcopy(zeros(1,int32(MAX_FMAP)));
  w_con1_input = coder.load('w_conv1_input.mat');
  w_conv1      = w_con1_input.data;

  O = I - F + 1;
  sz_fmap_in  = I * I;
  sz_fmap_out = O * O;                                                                                                                     

  % manually implemented line buffer and window buffer
  line_buffer   = zeros(F, I); % (3, 18)  
  window_buffer = zeros(F, F); % (3, 3)
  % [Placeholder] #pragma HLS array_partition variable=line_buffer complete dim=1
  % [Placeholder] #pragma HLS array_partition variable=window_buffer complete dim=0

  % pre-fill the line buffer
  coder.hdl.loopspec('unroll');
  for i = 1:F % pre-fetch 3 rows of input feature map
    coder.hdl.loopspec('pipeline');
    for j = 1:I
      line_buffer(i,j) = fmap_in((i-1)*I+j);
    end
  end

  for y = 1:O
    % pre-fill (F-1) rows of window buffer for computing new output row
    for i = 1:F
    coder.hdl.loopspec('pipeline');
      for j = 2:F
        window_buffer(i,j) = fmap_in((i-1+y-1)*I+j-1);
      end
    end
    for x = 1:O
      % update window buffer
      for i = 1:F
        for j = 1:(F-1)
          window_buffer(i,j) = window_buffer(i,j+1);
        end
      end
      % update last row
      for i = 1:F
        window_buffer(i,F) = line_buffer(i,F-1+x);
      end
      % update line buffer
      for i = 1:(F-1)
        line_buffer(i,x) = line_buffer(i+1,x);
      end
      % update last line buffer
      line_buffer(F,x) = fmap_in(x+(y-1)*I+F*I);
      % reach the end of this row, update extra two values in the line buffer
      if x == O
        for i = 1:(F-1) % === first extra value
          line_buffer(i,x+1) = line_buffer(i+1,x+1);
        end
        line_buffer(F,x+1) = fmap_in(x+1+(y-1)*I+F*I);
        for i = 1:(F-1) % === second extra value
          line_buffer(i,x+2) = line_buffer(i+1,x+2);
        end
        line_buffer(F,x+2) = fmap_in(x+2+(y-1)*I+F*I);
      end
      coder.hdl.loopspec('pipeline'); % The main compute loop
      for n = 1:N
        o_idx = x+(y-1)*O+(n-1)*sz_fmap_out;
        one_out = 0;
        num_mac = 0;
        %sum = 0;
        for r = 1:F
          for c = 1:F
            if do_mac(x-1+c,y-1+r,I,PADDING) % only compute non-padding pixels
              w_idx = c+(r-1)*F+(n-1)*F_SIZE;
              one_out = one_out + (~bitxor(window_buffer(r,c),w_conv1(w_idx))); % XNOR
              num_mac = num_mac + 1;
            end
          end
        end
        sum = one_out * 2 - num_mac;
        fmap_out(o_idx) = sum > threshold(o_idx);
      end
    end
  end
end

% utility function to neglect padding pixels
function Not_Padding = do_mac(x, y, I, PADDING)
  if x<=floor(PADDING/2) || x>(I-floor(PADDING/2)) || y<=floor(PADDING/2) || y>(I-floor(PADDING/2))
    Not_Padding = false;
  else
    Not_Padding = true;
  end 
end

% convolution layer 2
%  Input:  fmap_in   - input feature map
%          threshold - threshold for batchnorm operation
%          M         - number of input feature map
%          N         - number of output feature map
%          I         - width of input feature map
%  Output: fmap_out  - output feature map
%
% Optimization: data packing
%               packing factor is M = 16
function fmap_out = conv_layer_2(fmap_in, threshold, M, N, I, F, F_SIZE, PADDING, MAX_FMAP)
  fmap_out = coder.nullcopy(zeros(1,int32(MAX_FMAP)));
  packed_w_conv2_input = coder.load('packed_w_conv2_input.mat');
  packed_w_conv2       = packed_w_conv2_input.data;

  O = I - F + 1;
  sz_fmap_in  = I * I;
  sz_fmap_out = O * O;

  packed_input = NaN(int32(I),int32(I));
  %                    I  * I  * M
  % input feature map: 16 * 16 *16
  % pack input feature map accross the channel dimension
  for x = 1:I
  coder.hdl.loopspec('unroll');
    for y = 1:I
      i_idx = x+(y-1)*I;
      concate_data = uint16(fmap_in(i_idx));
      base = uint16(2);
      for m = 2:M
        i_idx = x+(y-1)*I+(m-1)*sz_fmap_in;
        if fmap_in(i_idx)
          concate_data = concate_data + base;
        end
        base = base * 2;
      end
      packed_input(x,y) = concate_data;
    end
  end
  % MAC and batchnorm
  for n = 1:N
    for x = 1:O
      coder.hdl.loopspec('pipeline');
      for y = 1:O
        sum = 0;
        o_idx = x+(y-1)*O+(n-1)*sz_fmap_out;
        one_out = int32(0);
        num_mac = 0;
        for c = 1:F
          for r = 1:F
            if do_mac(x-1+c,y-1+r,I,PADDING) % ignore the padding pixels
              packed_w_idx = c+(r-1)*F+(n-1)*F_SIZE;
              xor_res = bitxor(packed_input(x-1+c,y-1+r),packed_w_conv2(packed_w_idx));
              one_out = one_out + int32(popcount_16(bitcmp(uint16(xor_res))));
              num_mac = num_mac + M;
            end
          end
        end
        % one_out is changed to unsigned value for bitwise operations
        % changed back to signed values
        sum = int32(one_out) * 2 - num_mac;
        fmap_out(o_idx) = sum > threshold(o_idx);
      end
    end
  end
end

% utility function to count total number of 1s 
% popcount: uses bit-level parallelism for fast counting.
function x = popcount_16(x)
  m1 = uint16(0x5555);
  m2 = uint16(0x3333);
  m3 = uint16(0x0f0f);
  m4 = uint16(0x00ff);
  % pair counting, each two-bit segment of 'x' not contains the number of 1s in those two bits
  x  = bitand(x,m1)+bitand(bitshift(x,-1),m1);
  % nibble counting, four-bit segments
  x  = bitand(x,m2)+bitand(bitshift(x,-2),m2);
  % Byte counting, eight-bit segments
  x  = bitand(x,m3)+bitand(bitshift(x,-4),m3);
  % final accumulation
  x  = bitand(x,m4)+bitand(bitshift(x,-8),m4);
end

function x = popcount_32(x)
  m1 = uint32(0x55555555);
  m2 = uint32(0x33333333);
  m3 = uint32(0x0f0f0f0f);
  m4 = uint32(0x00ff00ff);
  m5 = uint32(0x0000ffff);
  x  = bitand(x,m1)+bitand(bitshift(x,-1),m1); 
  x  = bitand(x,m2)+bitand(bitshift(x,-2),m2);
  x  = bitand(x,m3)+bitand(bitshift(x,-4),m3);
  x  = bitand(x,m4)+bitand(bitshift(x,-8),m4);
  x  = bitand(x,m5)+bitand(bitshift(x,-16),m5);
end

% max pooling
%  Input:  fmap_in   - input feature map
%          M         - number of input feature map
%          I         - width of input feature map
%  Output: fmap_out  - output feature map
function fmap_out = max_pool(fmap_in, M, I, MAX_FMAP, STRIDE_MAX_POOL)
  fmap_out = coder.nullcopy(zeros(1,int32(MAX_FMAP)));
  O = I / 2;
  sz_fmap_in  = I * I;
  sz_fmap_out = O * O;
  % clear the buffer
  for i = 1:MAX_FMAP
    fmap_out(i) = 0;
  end
  % main loop
  coder.hdl.loopspec('pipeline');
  for m = 1:M
    for x = 1:O
      for y = 1:O
        o_idx = x+(y-1)*O+(m-1)*sz_fmap_out;
        max = 0;
        for c = 1:STRIDE_MAX_POOL
          for r = 1:STRIDE_MAX_POOL
            i_idx = STRIDE_MAX_POOL*(x-1)+c+(STRIDE_MAX_POOL*(y-1)+r-1)*I+(m-1)*sz_fmap_in;
            if fmap_in(i_idx)
              max = 1;
            end
          end
        end
        fmap_out(o_idx) = max;
      end
    end
  end
end

% reshape the output from conv layer
%  Input:  fmap_in   - output fmaps from the last conv layer
%  Output: fmap_out  - input fmaps of the first dense layer
function fmap_out = reshape_local(fmap_in, NUM_CHANNEL2, O_WIDTH, MAX_FMAP)
  fmap_out = coder.nullcopy(zeros(1,int32(MAX_FMAP)));
  coder.hdl.loopspec('pipeline');
  for c = 1:NUM_CHANNEL2
    for y = 1:O_WIDTH
      for x = 1:O_WIDTH
        o_idx = c+(x-1+(y-1)*O_WIDTH)*NUM_CHANNEL2;
        i_idx = x+(y-1)*O_WIDTH+(c-1)*O_WIDTH*O_WIDTH;
        fmap_out(o_idx) = fmap_in(i_idx);
      end
    end
  end
end

% fully connected layer 
%  Input:  fmap_in   - input feature map
%          threshold - threshold for batchnorm operation
%          M         - number of input feature map
%          N         - number of output feature map
%  Output: fmap_out  - output feature map
%
% Optimization: data packing
%               packing factor is 32
function fmap_out = fully_connect_1(fmap_in, M, N, MAX_FMAP)
  fmap_out = coder.nullcopy(zeros(1,int32(MAX_FMAP)));
  packed_w_fc1_input = coder.load('packed_w_fc1_input.mat');
  packed_w_fc1       = packed_w_fc1_input.data;
  b_fc1_input = coder.load('b_fc1_input.mat');
  b_fc1       = b_fc1_input.data;

  var_w = 2 / M; % How would this be achieved in the float2fix conversion?
  c = sqrt(var_w);
  % data packing
  packed_sz = M / 32;
  packed_input = NaN(1, int32(packed_sz));
  coder.hdl.loopspec('unroll');
  for x = 1:packed_sz
    i_idx = (x-1)*32+1;
    concate_data = uint32(fmap_in(i_idx));
    base = uint32(2);
    for y = 2:32
      i_idx = (x-1)*32+y;
      if fmap_in(i_idx)
        concate_data = concate_data + base;
      end
      base = base * 2;
    end
    packed_input(x) = concate_data;
  end
  % main loop
  coder.hdl.loopspec('pipeline');
  for n = 1:N
    one_out = int32(0);
    for m = 1:packed_sz
      packed_w_idx = (m-1)*N+n;
      xor_res = bitxor(packed_input(m),packed_w_fc1(packed_w_idx));
      one_out = one_out + int32(popcount_32(bitcmp(uint32(xor_res))));
    end
    one_out = (2*fi(one_out,1,16,4)-M)*c;
    biased  = one_out + b_fc1(n);
    fmap_out(n) = biased > 0;
  end
end



% fully connected layer 
%  Input:  fmap_in   - input feature map
%          threshold - threshold for batchnorm operation
%          M         - number of input feature map
%          N         - number of output feature map
%  Output: fmap_out  - output feature map
%
% Optimization: data packing
%               packing factor is 32
function fmap_out = fully_connect_2(fmap_in, M, N, MAX_FMAP)
  fmap_out = coder.nullcopy(zeros(1,int32(MAX_FMAP)));
  packed_w_fc2_input = coder.load('packed_w_fc2_input.mat');
  packed_w_fc2       = packed_w_fc2_input.data;
  b_fc2_input = coder.load('b_fc2_input.mat');
  b_fc2       = b_fc2_input.data;

  var_w = 2 / M;
  c = sqrt(var_w);
  max = fi(-100,1,32,8);
  % data packing
  packed_sz = M / 32;
  packed_input = NaN(1, int32(packed_sz));
  coder.hdl.loopspec('unroll');
  for x = 1:packed_sz
    i_idx = (x-1)*32+1;
    concate_data = uint32(fmap_in(i_idx));
    base = uint32(2);
    for y = 2:32
      i_idx = (x-1)*32+y;
      if fmap_in(i_idx)
        concate_data = concate_data + base;
      end
      base = base * 2;
    end
    packed_input(x) = concate_data;
  end
  % main loop
  coder.hdl.loopspec('pipeline');
  for n = 1:N
    one_out = int32(0);
    for m = 1:packed_sz
      packed_w_idx = (m-1)*N+n;
      xor_res = bitxor(packed_input(m),packed_w_fc2(packed_w_idx));
      one_out = one_out + int32(popcount_32(bitcmp(uint32(xor_res))));
    end
    one_out = (2*fi(one_out,1,16,4)-M)*c;
    biased = one_out+ b_fc2(n);
    if biased > max
      max = fi(biased,1,32,8);  % 0.83
      %max = fi(biased,1,16,4); % 0.79
      %max = biased;            % 0.82 % ML is surprising!
      fmap_out(n) = 1;
    else
      fmap_out(n) = 0;
    end
  end
end



