%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MATLAB test bench for the SpGEMM
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Sparse Marix C = Sparse Matrix A * Sparse Marix B
% Size of Matrix A: I * J
% Size of Matrix B: J * K
% Size of Matrix C: I * K
%
% This design computes SpGEMM in row-wise compute pattern, thus
% all matrices A, B, C are CSR-based format.
%

%   Copyright 2023 The MathWorks, Inc.

clear mlhdlc_spgemm;

BNAK_CAPACITY = 64;     % elements
I = 8;
J = 8;
K = 8;
MAT_A = [0,0,0,1,0,0,1,0; ...
         1,1,0,0,0,1,0,1; ...
         1,1,1,1,0,0,0,0; ...
         1,1,0,0,1,1,0,0; ...
         1,0,0,0,1,0,0,1; ...
         0,0,0,0,0,0,0,0; ...
         0,1,1,0,0,1,0,0; ...
         1,0,0,0,0,0,0,1];
MAT_B = MAT_A;
size_A_idx_tb = I + nnz(MAT_A);

% create matrix A in CSR format
A_idx_tb = zeros(1, size_A_idx_tb);
A_val_tb = zeros(1, size_A_idx_tb);
A_idx_tb_cnt = 0;
for i = 1:I
  for j = 1:J
    if MAT_A(i,j) ~= 0
      A_idx_tb_cnt = A_idx_tb_cnt + 1;
      A_idx_tb(A_idx_tb_cnt) = j;
      A_val_tb(A_idx_tb_cnt) = MAT_A(i,j);
    end
  end
  A_idx_tb_cnt = A_idx_tb_cnt + 1;
  A_idx_tb(A_idx_tb_cnt) = -1;
  A_val_tb(A_idx_tb_cnt) = 0;
end
% create matrix B in CSR format
% in this test case, matrix B is the same as matrix A
B_idx_tb = A_idx_tb;
B_val_tb = A_val_tb;
B_ptr_tb = zeros(1, K+1);
B_ptr_cnt = 1;
B_ptr_tb(B_ptr_cnt) = 1;
for i = 1:size(B_idx_tb,2)
  if B_idx_tb(i) == -1
    B_ptr_cnt = B_ptr_cnt + 1;
    B_ptr_tb(B_ptr_cnt) = i + 1;
  end
end

% Input pattern
% (nnz_A_row_idx, nnz_A_val, nnz_B_col_idx, nnz_B_val), ... , (0,0,-1,0)
% (nnz_A_row_idx, nnz_A_val, nnz_B_col_idx, nnz_B_val), ... , (0,0,-1,0)
% ..., (nnz_A_row_idx, nnz_A_val, nnz_B_col_idx, nnz_B_val), (-1,0,-1,0) 
% for the last packet of the current output row, attach special packet.
% (nnz_A_row_idx, nnz_A_val, nnz_B_col_idx, nnz_B_val), ... , (0,0,-1,0)
% (nnz_A_row_idx, nnz_A_val, nnz_B_col_idx, nnz_B_val), ... , (0,0,-1,0)
% ..., (nnz_A_row_idx, nnz_A_val, nnz_B_col_idx, nnz_B_val), (-1,0,-1,0) 
% ...
C_val = zeros(I, BNAK_CAPACITY);
C_idx = zeros(I, BNAK_CAPACITY);
A_row_idx = 1;

% call the xcel
for i = 1:size_A_idx_tb
  if A_idx_tb(i) == -1
    % send the special packet (-1,0,-1,0)
    % and receive the valid output row C
    [C_idx_out, C_val_out] = mlhdlc_spgemm(-1,0,-1,0);
    % store the valid outputs
    for j = 1:BNAK_CAPACITY
      C_val(A_row_idx,j) = C_val_out(j);
      C_idx(A_row_idx,j) = C_idx_out(j);
    end
    % update row index
    A_row_idx = A_row_idx + 1;
  else
    B_row_cnt  = 0;
    B_idx_base = B_ptr_tb(A_idx_tb(i));
    finish_condition = B_idx_tb(B_row_cnt+B_idx_base);
    mul_cnt = 0;
    while finish_condition ~= -1
      [C_idx_out, C_val_out] = mlhdlc_spgemm(A_row_idx,A_val_tb(i), finish_condition, B_val_tb(B_row_cnt+B_idx_base));
      % fetch next value from this row of matrix B
      B_row_cnt = B_row_cnt + 1;
      finish_condition = B_idx_tb(B_row_cnt+B_idx_base);
      mul_cnt = mul_cnt + 1;
    end
    % if this is not the last nnz in this row (of matrix A) and this nnz does contains valid multiplications
    if (A_idx_tb(i+1)) ~= -1 && (mul_cnt ~= 0) 
      [C_idx_out, C_val_out] = mlhdlc_spgemm(0,0,-1,0);
    end
  end 
end

% calculate reference results
MAT_C = MAT_A * MAT_B;

% verify the results
for i = 1:I
  col_cnt = 1;
  for k = 1:K
    if MAT_C(i,k) ~= 0
      if C_idx(col_cnt) == -1 % remove the -1
        col_cnt = col_cnt + 1;
      end 
      if MAT_C(i,k) ~= C_val(i,col_cnt) || k ~= C_idx(i,col_cnt)
        fprintf('Test FAILED! The (%d,%d) result not match - ref: %d, output: %d.\n', i, k, MAT_C(i,k), C_val(i,col_cnt));
      end
      col_cnt = col_cnt + 1;
    end
  end
end
