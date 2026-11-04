%%Let us take a random input "input"
%the output obtained from dct is stored in "output".

%   Copyright 2023 The MathWorks, Inc.
input= [  1.1047    1.1204    1.5747    1.4829    1.2321    0.4399    0.4396    0.4831
    0.4299    1.2515    1.5983    0.0291    1.5702    0.3180    0.1788    0.1890
    1.0827    1.5610    1.4725    0.4802    1.4903    1.5338    0.1678    1.4861
    1.1264    1.0797    1.4808    1.5223    1.1144    1.1186    1.5456    1.1655
    1.4148    0.3114    1.1333    1.5162    1.4879    0.0168    0.0388    1.3288
    0.0676    0.3253    0.1455    1.1726    0.4661    1.5907    1.0989    0.2572
    1.2253    0.0618    1.4772    1.1972    0.2716    1.2840    0.3432    1.1982
    0.2351    1.5558    1.1000    0.0047    0.2561    1.1489    0.2761    0.1455];


output = mlhdlc_dct(input);

%Here, the output is checked with the inverse discrete cosine transform

dct_matrix_inv = dctmtx(8)^-1;
idct = dct_matrix_inv *output*dct_matrix_inv';
check = idct-input;
