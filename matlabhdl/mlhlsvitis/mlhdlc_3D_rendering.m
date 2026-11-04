%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MATLAB design: 3D rendering
%
% Introduction:
% Process of creating a 2D image from a 3D model
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Input:  triangle_3ds - the 3D model
%                        2D array
%         angle - the projection angle
% Output: output_frame    - the 2D images rendering from the 3D model
%         2D array, the rendered 2D image.

%   Copyright 2023 The MathWorks, Inc.
%#codegen
function output_frame = mlhdlc_3D_rendering(triangle_3ds, angle)
% [Placeholder] Uncomment for interface optimization before release
% coder.hdl.interface('triangle_3ds','AXI4-Stream');
% coder.hdl.interface('output_frame','AXI4-Stream');

  % frame size
  MAX_X = 4;
  MAX_Y = 4;
  
  % local variables
  triangle_2d = zeros(1,7);
  % max-min index arrays
  % intermediate values for rasterization
  max_min = NaN(1, 5);
  max_idx = NaN(1, 1);

  % fragments and pixel buffer should be large enough 
  % to hold the updated pixels
  % fragments
  fragments = zeros(500, 4);

  % pixel buffer
  pixels = zeros(500, 3);

  % initialize the frame buffer for new rendering task
  output_frame = zeros(1, MAX_X*MAX_Y);

  % 3D rendering
  for i = 1:size(triangle_3ds,2)/9
    % [Placeholder] MATLAB Vitis HLS dataflow pragma
    triangle_3d = NaN(1,9);
    for j = 1:9
        triangle_3d(j) = triangle_3ds((i-1)*9+j);
    end
    triangle_2d = projection(triangle_3d, triangle_2d, angle);
    [flag, max_min, max_idx, triangle_2d] = rasterization1(triangle_2d, max_min, max_idx);
    [size_fragment, fragments] = rasterization2(flag, triangle_2d, max_min, max_idx, fragments);
    [size_pixels, pixels] = zculling(fragments, size_fragment, pixels);
    output_frame = coloringFB(size_pixels, pixels, output_frame);
  end  
end

% sub-tasks
function triangle_2d = projection (triangle_3d, triangle_2d, angle)
coder.inline('never');
  if angle == 0
    triangle_2d(1) = triangle_3d(1);
    triangle_2d(2) = triangle_3d(2);
    triangle_2d(3) = triangle_3d(4);
    triangle_2d(4) = triangle_3d(5);
    triangle_2d(5) = triangle_3d(7);
    triangle_2d(6) = triangle_3d(8);
    triangle_2d(7)  = floor(triangle_3d(3)/3) + floor(triangle_3d(6)/3) + floor(triangle_3d(9)/3);
  elseif angle == 1
    triangle_2d(1) = triangle_3d(1);
    triangle_2d(2) = triangle_3d(3);
    triangle_2d(3) = triangle_3d(4);
    triangle_2d(4) = triangle_3d(6);
    triangle_2d(5) = triangle_3d(7);
    triangle_2d(6) = triangle_3d(9);
    triangle_2d(7)  = floor(triangle_3d(2)/3) + floor(triangle_3d(5)/3) + floor(triangle_3d(8)/3);
  elseif angle == 2
    triangle_2d(1) = triangle_3d(3);
    triangle_2d(2) = triangle_3d(2);
    triangle_2d(3) = triangle_3d(6);
    triangle_2d(4) = triangle_3d(5);
    triangle_2d(5) = triangle_3d(9);
    triangle_2d(6) = triangle_3d(8);
    triangle_2d(7)  = floor(triangle_3d(1)/3) + floor(triangle_3d(4)/3) + floor(triangle_3d(7)/3);
  else
    triangle_2d(1) = 0;
    triangle_2d(2) = 0;
    triangle_2d(3) = 0;
    triangle_2d(4) = 0;
    triangle_2d(5) = 0;
    triangle_2d(6) = 0;
    triangle_2d(7)  = 0;
  end    
end

% Manually split the rasterization to two sub-stages
% To balance the dataflow (task-level pipeline) stages
function [flag, max_min, max_idx, triangle_2d] = rasterization1(triangle_2d, max_min, max_idx)
coder.inline('never');
  parameter_cw = check_clockwise(triangle_2d);
  if parameter_cw == 0
    flag = 1;
    return;
  elseif parameter_cw < 0
    flag = 0;
    triangle_2d = clockwise_vertices(triangle_2d);
  else
    flag = 0;
  end

  % find the rectangle bounds of 2D triangles
  max_min(1) = find_min(triangle_2d(1), triangle_2d(3), triangle_2d(5));
  max_min(2) = find_max(triangle_2d(1), triangle_2d(3), triangle_2d(5));
  max_min(3) = find_min(triangle_2d(2), triangle_2d(4), triangle_2d(6));
  max_min(4) = find_max(triangle_2d(2), triangle_2d(4), triangle_2d(6));
  max_min(5) = max_min(2) - max_min(1);

  % calculate index for searching pixels
  max_idx(1) = (max_min(2)-max_min(1))*(max_min(4)-max_min(3));
end

% Utility functions for rasterization1
function cw = check_clockwise(triangle_2d)
  % Determine whether three vertices of a triangle
  % (x0,y0) (x1,y1) (x2,y2) are in clockwise order by Pineda algorithm
  % if so, return cw > 0
  % else if three points are in line, return cw == 0
  % else in counterclockwise order, return cw < 0
  cw = (triangle_2d(5)-triangle_2d(1)) * (triangle_2d(4)-triangle_2d(2)) - ...
       (triangle_2d(6)-triangle_2d(2)) * (triangle_2d(3)-triangle_2d(1));
end

function triangle_2d = clockwise_vertices(triangle_2d)
  % swap (x0, y0) (x1, y1) of a triangle_2d
  tmp_x = triangle_2d(1);
  tmp_y = triangle_2d(2);
  triangle_2d(1) = triangle_2d(3);
  triangle_2d(2) = triangle_2d(4);
  triangle_2d(3) = tmp_x;
  triangle_2d(4) = tmp_y;
end

function min_val = find_min(in0, in1, in2)
  % find the minimal values from 3 integers
  if in0 < in1
    if in0 < in2
      min_val = in0;
    else
      min_val = in2;
    end
  else
    if in1 < in2
      min_val = in1;
    else
      min_val = in2;
    end
  end
end

function max_val = find_max(in0, in1, in2)
  % find the maximal values from 3 integers
  if in0 > in1
    if in0 > in2
      max_val = in0;
    else
      max_val = in2;
    end
  else
    if in1 > in2
      max_val = in1;
    else
      max_val = in2;
    end
  end
end

function [fragment_cnt, fragments] = rasterization2(flag, triangle_2d, max_min, max_idx, fragments)
coder.inline('never');
  fragment_cnt = 0;
  if flag % Not a valid triangle_2d
    return;
  end
  % specify the color
  color = 1;
  % iterate all the points in the bounding rectangle
  % manually rewrite the nested for loop for optimization
  for i = 1:max_idx(1)
    % calculate the coordinate of the points in the bounding rectangle
    x = max_min(1) + mod((i-1), max_min(5));
    y = max_min(3) + floor((i-1) / max_min(5));
    % update the fragment
    if pixel_in_triangle(x,y,triangle_2d)
      fragment_cnt = fragment_cnt + 1;
      fragments(fragment_cnt, 1)    = x+1;
      fragments(fragment_cnt, 2)    = y+1;
      fragments(fragment_cnt, 3)    = triangle_2d(7);
      fragments(fragment_cnt, 4)    = color;   
    end
  end
end

% Utility function for rasterization2
function res = pixel_in_triangle(x, y, triangle_2d)
  pi0 = (x-triangle_2d(1))*(triangle_2d(4)-triangle_2d(2)) - ...
        (y-triangle_2d(2))*(triangle_2d(3)-triangle_2d(1));
  pi1 = (x-triangle_2d(3))*(triangle_2d(6)-triangle_2d(4)) - ...
        (y-triangle_2d(4))*(triangle_2d(5)-triangle_2d(3));
  pi2 = (x-triangle_2d(5))*(triangle_2d(2)-triangle_2d(6)) - ...
        (y-triangle_2d(6))*(triangle_2d(1)-triangle_2d(5));
  res = (pi0 >= 0) && (pi1 >= 0) && (pi2 >= 0);
end

% filter hidden pixels
function [pixels_cnt, pixels] = zculling(fragments, size_fragment, pixels)
coder.inline('never');
  % frame size % define the same macro in the second time
  MAX_X = 256;
  MAX_Y = 256;
  % initialize the z-buffer in rendering the first triangle_2d of an image
  persistent z_buffer;

  % initialize the persistent varaible
  if isempty(z_buffer)
    z_buffer = ones(MAX_Y, MAX_X) * 255;
  end
  pixels_cnt = 0;
  % update z_buffer and pixels
  for i = 1:size_fragment
    % camera in (0,0,-1), anything closer to it is visible
    if fragments(i, 3) < z_buffer(fragments(i, 2), fragments(i, 1))
      pixels_cnt = pixels_cnt + 1;
      pixels(pixels_cnt, 1) = fragments(i, 1);
      pixels(pixels_cnt, 2) = fragments(i, 2);
      pixels(pixels_cnt, 3) = fragments(i, 4); 
      z_buffer(fragments(i, 2), fragments(i, 1)) = fragments(i, 3);
    end
  end
end

% color the frame buffer
function output_frame = coloringFB(size_pixels, pixels, output_frame)
coder.inline('never');
  % frame size % define the same macro in the third time
  MAX_X = 4;
  MAX_Y = 4;
  for i = 1:size_pixels
    output_frame((pixels(i, 1)-1)*MAX_X+pixels(i, 2)) = pixels(i, 3);
  end
end
