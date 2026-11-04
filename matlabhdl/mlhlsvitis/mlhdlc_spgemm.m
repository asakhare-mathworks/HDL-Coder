
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MATLAB design: sparse-matrix sparse-matrix multiplication (SpGEMM)
% 
% Introduction:
% key compute kernels in multiple applications including 
% all-pairs shortest-path algorithms, Markov clustering, 
% triangle counting, peer pressure clustering, etc.

%   Copyright 2023 The MathWorks, Inc.
%#codegen
%   Input:  A_idx  - matrix A non-zero element row index 
%           A_val  - matrix A non-zero element value 
%           B_idx  - matrix B non-zero element column index 
%           B_val  - matrix B non-zero element value
%   Output: C_idx_col - matrix C: one row of non-zero elements: 1D index array
%           C_val     - matrix C: one row of non-zero elements: 1D value array
function [C_idx_col, C_val] = mlhdlc_spgemm(A_idx, A_val, B_idx, B_val)
% [Placeholder] Uncomment for interface optimization before release
% coder.hdl.interface('A_idx','AXI4-Stream');
% coder.hdl.interface('A_val','AXI4-Stream');
% coder.hdl.interface('B_idx','AXI4-Stream');
% coder.hdl.interface('B_val','AXI4-Stream');
% coder.hdl.interface('C_val','AXI4-Stream');
% coder.hdl.interface('C_idx_col','AXI4-Stream');

  % parameters
  % SAFE to change based on your design specification
  NUM_BANKS = 2;      % empty banks for buffering partial scalar-vector product
  BNAK_CAPACITY = 64; % elements
  MAX_COL_IDX = 64;   % Possible maximum column index

  % task-level pipelining
  % [Pleaceholder] # pragma HLS dataflow
  [psum_idx_row, psum_idx_col, psum_val] = multiplication(A_idx, A_val, B_idx, B_val);
  [psum_buffer, psum_buffer_len, psum_bank_id_extra, switch_psum_buffer] = merge(psum_idx_row, psum_idx_col, psum_val, NUM_BANKS, BNAK_CAPACITY);
  [C_idx_col, C_val] = drain(psum_buffer, psum_buffer_len, psum_bank_id_extra, switch_psum_buffer, BNAK_CAPACITY, MAX_COL_IDX);
end

%% subfunctions
% multiplication
%   Input:  A_idx  - matrix A non-zero element row index 
%           A_val  - matrix A non-zero element value 
%           B_idx  - matrix B non-zero element column index 
%           B_val  - matrix B non-zero element value
%   Output: psum_idx_row - row index of output partial sum
%           psum_idx_col - column index of output partial sum
%           psum_val     - value of output partial sum
function [psum_idx_row, psum_idx_col, psum_val] = multiplication(A_idx, A_val, B_idx, B_val)
coder.inline('never');
  psum_idx_row = A_idx;
  psum_idx_col = B_idx;
  psum_val = A_val * B_val;  
end

% merge
%   Input:  psum_idx_row - row index of output partial sum
%           psum_idx_col - column index of output partial sum
%           psum_val     - value of output partial sum
%   Output: psum_buffer_out     - partial sum buffer
%           psum_buffer_len_out - length of valid data
%           psum_bank_id_extra  - the extra psum bank used for merge
%           switch_psum_buffer  - reach the end of merging one output row
%                                switch the double buffer 
function [psum_buffer_out, psum_buffer_len_out, psum_bank_id_extra, switch_psum_buffer] = merge(psum_idx_row, psum_idx_col, psum_val, NUM_BNAKS, BNAK_CAPACITY)
coder.inline('never');
  % output partial sum buffer 
  persistent psum_buffer;
  if isempty(psum_buffer)
    psum_buffer = zeros(uint32(NUM_BNAKS+1),uint32(BNAK_CAPACITY));
  end

  % record the length of valid data in each partial sum bank
  persistent psum_buffer_len;
  if isempty(psum_buffer_len)
    psum_buffer_len = zeros(1,uint32(NUM_BNAKS+1));
  end

  % The current read/write bank for merging the partial sum
  persistent write_bank_id;
  persistent read_bank_id;
  if isempty(write_bank_id)
    write_bank_id = 1;
  end
  if isempty(read_bank_id)
    read_bank_id = 1;
  end

  persistent empty_buffer;
  if isempty(empty_buffer)
    empty_buffer = true;
  end

  persistent write_cur_idx;
  persistent read_cur_idx;
  if isempty(write_cur_idx)
    write_cur_idx = 1;
  end
  if isempty(read_cur_idx)
    read_cur_idx = 1;
  end
  % merge partial rows
  if psum_idx_col ~= -1
    % if empty banks available, no need to merge
    if empty_buffer
      % no need to merge
      psum_buffer(uint32(write_bank_id),uint32(write_cur_idx))   = psum_idx_col;
      psum_buffer(uint32(write_bank_id),uint32(write_cur_idx+1)) = psum_val;
      write_cur_idx = write_cur_idx + 2;
    else % no empty banks, need merge
      % read bank empty, directly store the input packets.
      if psum_buffer_len(read_bank_id) <= read_cur_idx
        psum_buffer(uint32(write_bank_id),uint32(write_cur_idx))   = psum_idx_col;
        psum_buffer(uint32(write_bank_id),uint32(write_cur_idx+1)) = psum_val;
        write_cur_idx = write_cur_idx + 2;
      else % need merge
        if psum_buffer(uint32(read_bank_id),uint32(read_cur_idx)) > psum_idx_col
          psum_buffer(uint32(write_bank_id),uint32(write_cur_idx))   = psum_idx_col;
          psum_buffer(uint32(write_bank_id),uint32(write_cur_idx+1)) = psum_val;
          write_cur_idx = write_cur_idx + 2;
        elseif psum_buffer(uint32(read_bank_id),uint32(read_cur_idx)) == psum_idx_col
          psum_buffer(uint32(write_bank_id),uint32(write_cur_idx))   = psum_idx_col;
          psum_buffer(uint32(write_bank_id),uint32(write_cur_idx+1)) = psum_val + psum_buffer(uint32(read_bank_id),uint32(read_cur_idx+1));
          write_cur_idx = write_cur_idx + 2;
          read_cur_idx  = read_cur_idx + 2;
        else
          % keep reading data from psum buffer until reaching equal or larger
          % index or the end of psum buffer
          while (psum_buffer(uint32(read_bank_id), uint32(read_cur_idx)) < psum_idx_col) && psum_buffer_len(read_bank_id) > read_cur_idx
            psum_buffer(uint32(write_bank_id),uint32(write_cur_idx))   = psum_buffer(uint32(read_bank_id),uint32(read_cur_idx));
            psum_buffer(uint32(write_bank_id),uint32(write_cur_idx+1)) = psum_buffer(uint32(read_bank_id),uint32(read_cur_idx+1));
            write_cur_idx = write_cur_idx + 2;
            read_cur_idx  = read_cur_idx + 2;
          end   
          if psum_buffer(uint32(read_bank_id),uint32(read_cur_idx)) == psum_idx_col % if reaching equal index, accumulate them
            psum_buffer(uint32(write_bank_id),uint32(write_cur_idx))   = psum_idx_col;
            psum_buffer(uint32(write_bank_id),uint32(write_cur_idx+1)) = psum_val + psum_buffer(uint32(read_bank_id),uint32(read_cur_idx+1));
            write_cur_idx = write_cur_idx + 2;
            read_cur_idx  = read_cur_idx + 2;
          else % write the current input packet into the write buffer
            psum_buffer(uint32(write_bank_id),uint32(write_cur_idx))   = psum_idx_col;
            psum_buffer(uint32(write_bank_id),uint32(write_cur_idx+1)) = psum_val;
            write_cur_idx = write_cur_idx + 2;
          end
        end
      end
    end
  % update the bank_id for storing next row of partial sum
  else
    % check if values left in the read bank, if so, copy them to the write buffer
    if (~empty_buffer)
      for i=read_cur_idx:2:psum_buffer_len(read_bank_id)-1
        psum_buffer(uint32(write_bank_id),uint32(write_cur_idx))   = psum_buffer(uint32(read_bank_id),uint32(i));
        psum_buffer(uint32(write_bank_id),uint32(write_cur_idx+1)) = psum_buffer(uint32(read_bank_id),uint32(i+1));
        write_cur_idx = write_cur_idx + 2;
      end
    end
    % store the length of valid data
    psum_buffer_len(write_bank_id) = write_cur_idx;
    write_cur_idx = 1;
    read_cur_idx = 1;
    % update ids
    if write_bank_id == NUM_BNAKS + 1
      write_bank_id = 1;
    else
      write_bank_id = write_bank_id + 1;
    end
    if write_bank_id == NUM_BNAKS + 1
      read_bank_id = 1;
    else
      read_bank_id = read_bank_id + 1;
    end
  end
  % update empty buffer
  if write_bank_id == NUM_BNAKS + 1
    empty_buffer = false;
  end
  % save the extra bank id
  psum_bank_id_extra = write_bank_id;
  % output data
  psum_buffer_out = psum_buffer;
  psum_buffer_len_out = psum_buffer_len;

  % reset variables
  if psum_idx_col == -1 && psum_idx_row == -1
    write_bank_id = 1;
    empty_buffer = true;
    switch_psum_buffer = 1;
    for i = 1:NUM_BNAKS + 1
      psum_buffer_len(i) = 0;
    end
  else
   switch_psum_buffer = 0;
  end
end

% drain
%   Input:  psum_buffer        - output partial sum buffer
%           psum_buffer_len    - length of valid data
%           psum_bank_id_extra - the extra psum bank used for merge
%           switch_psum_buffer - flag for draining the data
%   Output: C_idx_col - matrix C: one row of non-zero elements: 1D index array
%           C_val     - matrix C: one row of non-zero elements: 1D value array
function [C_idx_col, C_val] = drain(psum_buffer, psum_buffer_len, psum_bank_id_extra, switch_psum_buffer,BANK_CAPACITY, MAX_COL_IDX)
coder.inline('never');
  C_idx_col = zeros(1,uint32(BANK_CAPACITY));
  C_val     = zeros(1,uint32(BANK_CAPACITY));
  num_bank  = size(psum_buffer_len,2);
  read_cur_idx = ones(1, num_bank);
  read_flag = ones(1, num_bank);
  compare_array = zeros (1, num_bank);
  drain_flag    = zeros(1, num_bank);
  drain_cur_idx = 1;

  % merge the partial row to generate one output row
  if switch_psum_buffer
    % No data left in the psum buffer, draining finished.
    drain_done = true;
    for i = 1:num_bank
      if i ~= psum_bank_id_extra && psum_buffer_len(i) > read_cur_idx(i)
        drain_done = false;
      end
    end

    while(~drain_done)
      % fetch valid data from psum banks 
      for i = 1:num_bank
        if i ~= psum_bank_id_extra
          % need to read data and also available
          if read_flag(i) == 1
            if read_cur_idx(i) < psum_buffer_len(i)
              compare_array(i) = psum_buffer(i,uint32(read_cur_idx(i)));
              read_cur_idx(i) = read_cur_idx(i) + 2; % idx + val
            else
              compare_array(i) = MAX_COL_IDX;
            end
          end
        else
          compare_array(i) = MAX_COL_IDX;
        end
      end
      % find minimal valid index
      min_idx = MAX_COL_IDX;
      for i = 1:num_bank
        if compare_array(i) < min_idx
          min_idx = compare_array(i);
        end
      end
      drain_data = 0;
      % find & compute the data to drain
      no_data_left = true;
      for i = 1:num_bank
        if min_idx == compare_array(i)
          drain_flag(i) = 1;
          drain_data = drain_data + psum_buffer(i,uint32(read_cur_idx(i)-1));
        else
          drain_flag(i) = 0;
        end
        if compare_array(i) ~= MAX_COL_IDX && compare_array(i) ~= min_idx
          no_data_left = false;
        end
      end
      % output value
      C_idx_col(drain_cur_idx)  = min_idx;
      C_val(drain_cur_idx)      = drain_data;
      drain_cur_idx             = drain_cur_idx + 1;

      % update read_flag
      % record the index of the consumed data, need to read a new one in
      % the next iteration if available
      for i = 1:num_bank
        if drain_flag(i)
          read_flag(i) = drain_flag(i);
        else
          read_flag(i) = 0;
        end
      end
      % update the drain_done
      drain_done_cnt = 0;
      % count the number of banks that drains all valid data
      for i = 1:num_bank
        if i == psum_bank_id_extra
          drain_done_cnt = drain_done_cnt + 1;
        else
          if psum_buffer_len(i) <= read_cur_idx(i)
            drain_done_cnt = drain_done_cnt + 1;
          end
        end
      end
      % no valid data left in paritial sum banks + no un-drained data on the fly
      if drain_done_cnt == num_bank && no_data_left
        drain_done = true;
      end
    end
  end
end
