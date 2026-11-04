%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MATLAB test bench for the vvadd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%   Copyright 2023 The MathWorks, Inc.

clear mlhdlc_vvadd;

ARRAY_SIZE = 16;
MIN_VAL = 0;
MAX_VAL = 8;
TOLENCE = 1e-7;

op1     = randi([MIN_VAL, MAX_VAL], 1, ARRAY_SIZE);
op2     = randi([MIN_VAL, MAX_VAL], 1, ARRAY_SIZE);
res     = zeros(1, ARRAY_SIZE);
res_ref = zeros(1, ARRAY_SIZE);

    % calculate reference results
for i = 1:ARRAY_SIZE
    res_ref(i) = op1(i)+op2(i);
end

% call the xcel
res = mlhdlc_vvadd(op1, op2);

% verify the results
for i = 1:ARRAY_SIZE
    fprintf('%d -- res_ref: %d; res: %d; op1: %d; op2: %d;\n', i, res_ref(i), res(i), op1(i), op2(i));
    if abs(res(i) - res_ref(i)) > TOLENCE
        disp(abs(res(i) - res_ref(i)));
        fprintf('Test FAILED! The %d-th result not match.\n', i);
    end
end
