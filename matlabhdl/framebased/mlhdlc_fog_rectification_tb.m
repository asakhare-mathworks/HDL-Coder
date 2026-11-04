function mlhdlc_fog_rectification_tb

I = imread('inputFogRectification.png');
R = I(:,:,1);
G = I(:,:,2);
B = I(:,:,3);

% To make testbench run faster, use |codegen command|. Comment this out for
% HDL Code generation.
% codegen -args {R,G,B} mlhdlc_fog_rectification
% [Rout, Gout, Bout] = mlhdlc_fog_rectification_mex(R,G,B);

% Comment this line if you are using code generation to run faster using
% previous section
[Rout, Gout, Bout] = mlhdlc_fog_rectification(R,G,B);

out = cat(3, Rout, Gout, Bout);

figure(1);
subplot(1,2,1),imshow(I);
subplot(1,2,2),imshow(out);
