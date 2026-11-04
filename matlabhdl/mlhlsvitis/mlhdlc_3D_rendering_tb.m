%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MATLAB test bench for 3D Rendering
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%   Copyright 2023 The MathWorks, Inc.

clear mlhdlc_3D_rendering

% frame size
MAX_X = 4;
MAX_Y = 4;

% read the 3D model
filename = fopen('mlhdlc_3D_rendering_tiny_fake.txt','r');
fileContent = '';

% read file line by line
tline = fgets(filename);
while ischar(tline) % get rid of the comment lines
  if isempty(strfind(tline, '%'))
    fileContent = [fileContent, tline];
  end
  tline = fgets(filename);
end
fclose(filename);
% format the 2D MATLAB matrix
formattedContent = strrep(fileContent, '{','[');
formattedContent = strrep(formattedContent, '}',']');
data = eval(formattedContent);

% set the angle
angle = 0;
num_triangle_3ds = size(data,1);
triangle_3ds = zeros(1, num_triangle_3ds*9);

% format the data - 1D array
for i = 1:num_triangle_3ds
  triangle_3ds((i-1)*9+1) = data(i,1); % x0
  triangle_3ds((i-1)*9+2) = data(i,2); % y0
  triangle_3ds((i-1)*9+3) = data(i,3); % z0
  triangle_3ds((i-1)*9+4) = data(i,4); % x1
  triangle_3ds((i-1)*9+5) = data(i,5); % y1
  triangle_3ds((i-1)*9+6) = data(i,6); % z1
  triangle_3ds((i-1)*9+7) = data(i,7); % x2
  triangle_3ds((i-1)*9+8) = data(i,8); % y2
  triangle_3ds((i-1)*9+9) = data(i,9); % z2
end

% call the xcel
res = mlhdlc_3D_rendering(triangle_3ds, angle);

% load golden results
file_res = fopen('mlhdlc_3D_rendering_tiny_fake_golden_res.txt', 'r');

% read the file line by line and store each line in a cell array
lines = textscan(file_res, '%s', 'Delimiter', '\n');
lines = lines{1};
fclose(file_res);
% filter out comment lines starting with '%'
lines = lines(cellfun(@(x) isempty(strfind(x, '%')), lines));

% initialize an empty array
numRows = length(lines);
numCols = max(cellfun(@length, lines));
ref_res = zeros(numRows, numCols);

% propagate the data
for i = 1:numRows
  for j = 1:length(lines{i})
    ref_res(i,j) = str2double(lines{i}(j));
  end
end

% To ensure the consistence with the reference image,
% scan the output frame from the upper right corner
scanned_res = zeros(1,MAX_X*MAX_Y);
cnt = 0;
% j - x axis
% i - y axis
for j = MAX_X:-1:1
  for i = 1:MAX_Y
    cnt = cnt + 1;
    scanned_res(cnt) = res((i-1)*MAX_Y+j);
  end
end

% Testcase 1
test_pass = true;
mismatch_pixel = 0;
cnt = 0;
% Check the results
for i = 1:MAX_Y
  for j = 1:MAX_X
    cnt = cnt + 1;
    if ref_res(i,j) ~= scanned_res(cnt)
      test_pass = false;
      mismatch_pixel = mismatch_pixel + 1;
    end
  end
end

if test_pass
  disp('TestCase 1 PASSED!');
else
  fprintf('TestCast 1 failed ... Number of mismatched pixels: %d. \n', mismatch_pixel);
end

% Testcase 2
% set the angle
angle = 1;

% call the xcel
res = mlhdlc_3D_rendering(triangle_3ds, angle);
res_ref = [0,0,0,0,0,1,1,0,0,0,1,0,0,0,0,0]';
test_pass = true;
mismatch_pixel = 0;
% Check the results
for i = i:size(res_ref,2)
    disp(res_ref(i) == res(i));
    if res(i) ~= ref_res(i)
        test_pass = false;
        mismatch_pixel = mismatch_pixel + 1;
    end
end

if test_pass
  disp('TestCase 2 PASSED!');
else
  fprintf('TestCase 2 failed ... Number of mismatched pixels: %d. \n', mismatch_pixel);
end

% Testcase 3
% set the angle
angle = 2;

% call the xcel
res = mlhdlc_3D_rendering(triangle_3ds, angle);

res_ref = [0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0]';
test_pass = true;
mismatch_pixel = 0;
% Check the results
for i = i:length(res_ref)
    if res(i) ~= ref_res(i)
        test_pass = false;
        mismatch_pixel = mismatch_pixel + 1;
    end
end

if test_pass
  disp('TestCase 3 PASSED!');
else
  fprintf('TestCase 3 failed ... Number of mismatched pixels: %d. \n', mismatch_pixel);
end

% Testcase 4
% set the angle
angle = 3;

% call the xcel
res = mlhdlc_3D_rendering(triangle_3ds, angle);

res_ref = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]';
test_pass = true;
mismatch_pixel = 0;
% Check the results
for i = i:length(res_ref)
    if res(i) ~= ref_res(i)
        test_pass = false;
        mismatch_pixel = mismatch_pixel + 1;
    end
end

if test_pass
  disp('TestCase 4 PASSED!');
else
  fprintf('TestCase 4 failed ... Number of mismatched pixels: %d. \n', mismatch_pixel);
end


