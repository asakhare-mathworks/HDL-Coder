function mlhdlc_hdlram_tb
%

%   Copyright 2012-2015 The MathWorks, Inc.

clear mlhdlc_hdlram_explicit;
clear mlhdlc_hdlram_implicit;

data = 100:200;
explicit_hdlram_out = zeros(1, length(data));
implicit_hdlram_out = zeros(1, length(data));

for ii=1:100
    ring_in = data(ii);
    [explicit_hdlram_out(ii)] = mlhdlc_hdlram_explicit(ring_in);
    [implicit_hdlram_out(ii)] = mlhdlc_hdlram_implicit(ring_in);
end

figure('Name', [mfilename, '_plot']);
subplot(2,1,1);
plot(1:100,data(1:100));
title('Input data to the ring counter')

subplot(2,1,2); 
plot(1:100,explicit_hdlram_out(1:100));
hold
plot(1:100,implicit_hdlram_out(1:100),'r');
legend({'explicit hdlram','implicit hdlram'});

end
