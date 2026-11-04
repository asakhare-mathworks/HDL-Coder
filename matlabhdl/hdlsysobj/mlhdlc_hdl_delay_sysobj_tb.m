% Testbench for hdl_delay_design
% Input signal
inputSignal = [1, 2, 3, 4, 5, 6, 7, 8];

% Preallocate output
outputSignal = zeros(size(inputSignal));

% Run the design function
for i = 1:length(inputSignal)
    outputSignal(i) = mlhdlc_hdl_delay_sysobj(inputSignal(i));
end

% Display results
disp('Input Signal:');
disp(inputSignal);
disp('Output Signal (Delayed):');
disp(outputSignal);

% Plot for visualization
figure;
stem(1:length(inputSignal), inputSignal, 'b', 'DisplayName', 'Input');
hold on;
stem(1:length(outputSignal), outputSignal, 'r', 'DisplayName', 'Output (Delayed)');
legend;
xlabel('Sample Index');
ylabel('Signal Value');
title('hdl.Delay Simulation');
grid on;
