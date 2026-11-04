%function max_ulp_diff = matlab_script(exponents) 
function max_ulp_diff = matlab_script(test_function, latency, mdlName, exp_first, exp_last)
diary('testbench_values');
tic  
%warning('off','all');%#TestStandardOutOfModel:WarningOffAll:ToBeAddressedLater
%warning;
global max_diffs
    max_diffs = [];
    %if nargin == 0
      % exponents = [15 23];
      %All positive exps
      % exponents = 1:127;
      %exponents = [1 5];
      exponents = exp_first: exp_last; 
    %end
    max_ulp_diff = 0;

    %%%%%%%%%%%%
    
    for ii=1:numel(exponents)
        max_ulp_diff_t = test_log_for_exp(exponents(ii), test_function, latency, mdlName);
        max_ulp_diff = max(max_ulp_diff, max_ulp_diff_t);
    end
    
    fprintf('\n\n########## Maximum ulp difference observed in entire specified range : %d\n', max_ulp_diff);
    toc
    diary off;
end

function max_ulp_diff = test_log_for_exp(exp, test_function, latency, mdlName)
    disp(test_function);
    global max_diffs
    max_ulp_diff = 0;
    inputs = get_all_mantissa_with_exp(exp);
    
    fprintf('Testing exponent %d. Values between : [%.10G %.10G]: \n', exp, min(inputs), max(inputs));
    print_num('min_input', min(inputs));
    print_num('max_input', max(inputs));    
   
    %out_matlab = log(inputs);
    out_matlab = test_function(inputs);
    
    %%%% ADD THE CODE to simulate in Simulink (similar to what we have done
    %%%% for Jeff's case).
    %latency = 23;
    [~,inputsize] = size(inputs);
    stoptime = inputsize + latency;
    assignin('base', 'stoptime', stoptime);
    assignin('base', 'input_exp', exp);
    
    %sim('testbench_LOG');
    sim(mdlName);
    
    out_algo1 = out_algo(latency+1:stoptime)';
    
   accuracy_metrics =  max((abs(out_algo1 - out_matlab))./max(abs(out_algo1),abs(out_matlab)));
    
   fprintf('\t Functional accuracy : %d\n', accuracy_metrics );
      
    raw_matlab = typecast(out_matlab, 'int32');
    raw_algo   = typecast(out_algo1, 'int32');
   
    %raw_diff = abs(raw_matlab - raw_algo);
   raw_diff = abs(raw_matlab - raw_algo);
  %%%%%%%%%% 
   %raw_diff1 = abs(raw_matlab(1:8388585) - raw_algo(23:8388607));
   %raw_diff2  = abs(raw_matlab(24:8388608) - raw_algo(24:8388608));
   
   fprintf('\t Raw diff : %d\n', max(raw_diff));
   %fprintf('\t Raw diff1 : %d\n', raw_diff1);
   %fprintf('\t Raw diff2 : %d\n', raw_diff2);
   
    fprintf('Result ----------> \n');  
    %print_num('min_output', min(out_algo1));
    %print_num('max_output', max(out_algo1));      
    fprintf('\t Summary: Max ulp difference observed in range : %d\n', max(raw_diff));
    max_ulp_diff = max(max_ulp_diff, max(raw_diff));
    
    fprintf('\t  : %d\n', max(raw_diff));
    max_ulp_diff = max(max_ulp_diff, max(raw_diff));
    
    
    if max(raw_diff) > 1
        fprintf('\t############ TOLERANCE ERROR with exponent = %d ###################\n', exp);  
        diffs = inputs(raw_diff == max(raw_diff));
        assignin('base', 'diffs', diffs);
        max_diffs = [max_diffs diffs(:)'];
        assignin('base', 'inputs_more_than_one_ulp_error', max_diffs);
    end
    fprintf('\n\n\n');
end

function values = get_all_mantissa_with_exp(e)    
    values = uint32(0):uint32(2^23-1);
    values = typecast(bitor(bitshift(uint32(e+127), 23), values), 'single');     
end

 function  print_num(title, value)
  value = single(value);
  bstr = bin(sflt(value));
  bstr = [bstr(1) char(124) bstr(2:9) char(124) bstr(10:end)];
  fprintf('%15s: %16.10G : %15d : %s\n', title, value, storedInteger(sflt(value)), bstr);
end

function f = sflt(d)
   bits = typecast(single(d), 'uint32');
   f = fi(reinterpretcast(bits, numerictype(0,32,0)), hdlfimath);
end


 
