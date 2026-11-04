%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MATLAB test bench for the SpMV
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear mlhdlc_spmv;

%   Copyright 2023 The MathWorks, Inc.
I_tb    = 8;  
J_tb    = 256;
num_nnz = 20;
num_input = I_tb + num_nnz;

x_tb = ones(1,J_tb);
res_ref = zeros(1, J_tb);
A_nnz_tb = [1,1,2,2,8,2,0,4];

% hard coded example
A_idx_tb = [3, -1, ...
            49, -1, ...
            1, 5, -1, ...
            2, 4, -1, ...
            1, 7, 30, 40, 59, 66, 127, 211, -1,...
            5, 60, -1,...
            -1, ...
            1, 47, 69, 117, -1];
A_val_tb = ones(1, num_input);

% call the xcel
res = mlhdlc_spmv(A_idx_tb, A_val_tb, x_tb);

% compute the reference results - SpMV
row_idx_tb = 1;
nnz_count_tb = 0;
for i = 1:num_input
    if A_idx_tb(i) == -1
        row_idx_tb = row_idx_tb + 1;
    else    
        res_ref(row_idx_tb) = res_ref(row_idx_tb) + A_val_tb(i) * x_tb(A_idx_tb(i));
    end
end

% verify the results
for i = 1:I_tb
    if abs(res(i) - res_ref(i)) > 1e-5
        fprintf('Test FAILED! The %d-th result not match.', i);
    end
end

