%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MATLAB design: Sparse-matrix dense-vector multiplication (SpMV)
% 
% Introduction:
% One of the basic kernels in sparse linear algebra (SLA), which is the 
% dominant compute kernel in applications like PageRank, Power Iteration, etc.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% sparse matrix A * dense vector x = dense vector y
% In this design, we compute the SpMV using inner product, thus the sparse 
% matrix A is stored in a CSR format
% A_val: non-zero values 
% A_idx: column indices of these non-zero values
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Current design
% To achieve high throughput, manually flatten the nested loop.
% To fulfill this optimization, adding a special packet of (-1, 0)
% at the end of each row as a notification.
%

%   Copyright 2023 The MathWorks, Inc.
% We assume the input dense vector can be fitted into the on-chip buffer.
% In other words, tiling is processed by the host machine and feeding 
% this accelerator with tiled data.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This example demonstrates the usage of pipeline loop pragma
% for the MATLAB to HLS flow

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%#codegen
function y = mlhdlc_spmv(A_idx, A_val, x)
% [Placeholder] Uncomment for interface optimization before release
% coder.hdl.interface('A_idx','AXI4-Stream');
% coder.hdl.interface('A_val','AXI4-Stream');
% coder.hdl.interface('x','AXI4-Stream');
% coder.hdl.interface('y','AXI4-Stream');

    % obtain the size of input values %
    nnz = size(A_idx,2);
    J   = size(x,2);

    % Hardware macros
    % cpacity of operand buffer for buffering x
    BYTES_PER_WORD = int32(4);   % 4 bytes per word, 32-bit 
    oper_size = int32(1);        % KB
    oper_capacity = oper_size*1024/BYTES_PER_WORD; % J_tb
    % psum buffer for buffering y
    psum_capacity = 8; % I_tb

    % check the size of input dense vector
    assert(J <= oper_capacity, 'input dense vector must smaller than the capacity of on-chip operand buffer, please tile it.');

    % define output without the unnecessary initialization
    y = coder.nullcopy(zeros(1,psum_capacity));

    % operand buffer and partial sum buffer
    persistent oper_buffer;
    persistent psum_buffer;
    % local registers
    persistent row_idx;

    % initialize the local SRAMs and registers
    oper_buffer = zeros(1,oper_capacity);
    psum_buffer = zeros(1,psum_capacity);
    row_idx     = 1;

    coder.hdl.loopspec('pipeline',1);
    % preload the dense vector x
    for j = 1:J
        oper_buffer(j) = x(j);
    end

    accu = 0;
    coder.hdl.loopspec('pipeline',1);
    % SpMV
    for i = 1:nnz
        if A_idx(i) == -1
            psum_buffer(row_idx) = accu;
            row_idx = row_idx + 1;
            accu = 0;
        else
            accu = accu + A_val(i) * oper_buffer(A_idx(i));
        end
    end

    coder.hdl.loopspec('pipeline');
    % output result
    for i = 1:psum_capacity
        y(i) = psum_buffer(i);
    end
end
