 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MATLAB test bench for Binarized Neural Network (BNN) digit recongnition
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%   Copyright 2023 The MathWorks, Inc.

clear mlhdlc_bnn

% helper function: load csv file and save it as a 'mat' data struct
function load_save_csv(filename, data_name, data_size)
  fileID      = fopen(filename, 'r');
  line        = fgetl(fileID);
  data_struct = textscan(line,'%f',data_size,'Delimiter',','); 
  data        = data_struct{1}; % fetch the first row  
  fclose(fileID);
  save(data_name,'data');
end

% number of test images
% To speed up the simulation, change the TEST_SIZE to 1
TEST_SIZE = 100;
PIXELS_PER_IMAGE = 256;
BUS_WIDTH = 32; % 32-bit

% read test images
data_dir = fullfile(matlabroot, 'toolbox', 'hdlcoder', 'hdldesignpatterns', 'matlabhdl', 'mlhlsvitis', 'mlhdlc_bnn_data');
test_images = fullfile(data_dir, 'test_b.dat');
File_test_images = fopen(test_images, 'r');
Test_images = fscanf(File_test_images, '%d',[1,TEST_SIZE*PIXELS_PER_IMAGE]);
fclose(File_test_images);

% load the test labels
test_labels = fullfile(data_dir, 'label.dat');
File_test_labels = fopen(test_labels, 'r');
Test_labels = fscanf(File_test_labels, '%d',[1,TEST_SIZE]);
fclose(File_test_labels);

%% load data used in the design file
SZ_W_CONV1 = 3 * 3 * 16;            % F*F*NUM_CHANNEL1
SZ_W_CONV2 = 3 * 3 * 16 * 32 / 16;  % F*F*NUM_CHANNEL1*NUM_CHANNEL2/pack_factor(16)
SZ_W_FC1   = 4 * 4 * 32 * 256 / 32; % NUM_FC1_IN*NUM_FC2_IN/packed_factor(32)
SZ_W_FC2   = 256 * 10 / 32;         % NUM_FC2_IN*NUM_FC2_OUT/packed_factor(32)
% load pre-trained weights
load_save_csv(fullfile(data_dir, 'weight_0b'),'w_conv1_input.mat',SZ_W_CONV1);
load_save_csv(fullfile(data_dir, 'packed_weight_5b'),'packed_w_conv2_input.mat',SZ_W_CONV2);
load_save_csv(fullfile(data_dir, 'packed_weight_10b'),'packed_w_fc1_input.mat',SZ_W_FC1);
load_save_csv(fullfile(data_dir, 'packed_weight_12b'),'packed_w_fc2_input.mat',SZ_W_FC2);

SZ_THRESHOLD1 = 16 * 16 * 16; % I_WIDHT1*I_WIDHT1*NUM_CHANNEL1
SZ_THRESHOLD2 = 8 * 8 * 32;   % I_WIDTH2*I_WIDTH2*NUM_CHANNEL2
% load batchnorm threshold
load_save_csv(fullfile(data_dir, 'batchnorm1'),'threshold1_input.mat',SZ_THRESHOLD1);
load_save_csv(fullfile(data_dir, 'batchnorm2'),'threshold2_input.mat',SZ_THRESHOLD2);

SZ_BIAS_FC1 = 256; % NUM_FC2_IN
SZ_BIAS_FC2 = 10;  % NUM_FC2_OUT
% load bias used in fully-connected layer
load_save_csv(fullfile(data_dir, 'weight_11p'),'b_fc1_input.mat',SZ_BIAS_FC1);
load_save_csv(fullfile(data_dir, 'weight_13p'),'b_fc2_input.mat',SZ_BIAS_FC2);

correct_prediction = 0;
predict_number_buffer = zeros(1,TEST_SIZE);
% call the xcel and count the correct prediction
for i=1:TEST_SIZE
  for j=1:PIXELS_PER_IMAGE/BUS_WIDTH
    idx_start = (i-1)*PIXELS_PER_IMAGE+(j-1)*BUS_WIDTH+1;
    idx_end   = (i-1)*PIXELS_PER_IMAGE+j*BUS_WIDTH;
    predict_number = mlhdlc_bnn(Test_images(idx_start:idx_end));
  end
  %disp(predict_number);
  predict_number_buffer(i) = predict_number;
  if Test_labels(i) == predict_number
    correct_prediction = correct_prediction + 1; 
  end
end

% print out the accuracy
fprintf("BNN digit recongnition - Accuracy: %f.\n", correct_prediction/TEST_SIZE);

% draw the handwritten digits
for i = 1:TEST_SIZE
  image_src = Test_images((i-1)*PIXELS_PER_IMAGE+1:i*PIXELS_PER_IMAGE);
  imageMatrix = reshape(~image_src, 16,16);
  newSize = [1024,1024];
  scaledImage = imresize(imageMatrix, newSize);
  imshow(scaledImage);
  % Add a textbox
  annotation('textbox', [0.11, 0.04, 0.1, 0.1], 'String', 'Label:'+string(Test_labels(i)), 'Color', 'black', 'FontSize', 24);
  if Test_labels(i) == predict_number_buffer(i)
      disp_color = 'green';
  else
      disp_color = 'red';
  end
  annotation('textbox', [0.35, 0.04, 0.1, 0.1], 'String', 'Prediction:'+string(predict_number_buffer(i)), 'Color', disp_color, 'FontSize', 24);
  pause(1);
end
