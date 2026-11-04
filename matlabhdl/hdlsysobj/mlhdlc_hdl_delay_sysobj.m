function y = mlhdlc_hdl_delay_sysobj(u)
%#codegen
% HDL-compatible delay using hdl.Delay
persistent delayObj;
if isempty(delayObj)
    delayObj = hdl.Delay('Length', 3);  % 3-cycle delay
end
y = delayObj(u);
