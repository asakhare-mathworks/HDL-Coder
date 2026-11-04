% Testbench for peak_detector_pipeline

inputSignal = [1, 3, 2, 5, 4, 6, 2, 7, 1];
outputPeak = zeros(size(inputSignal));

for i = 1:length(inputSignal)
    outputPeak(i) = mlhdlc_basic_peak(inputSignal(i));
end

disp('Input Signal:');
disp(inputSignal);
disp('Detected Peak Over Time:');
disp(outputPeak);

% Plot
figure;
plot(inputSignal, 'b-o', 'DisplayName', 'Input');
hold on;
plot(outputPeak, 'r-s', 'DisplayName', 'Peak');
legend;
xlabel('Sample Index');
ylabel('Amplitude');
title('Pipelined Peak Detector with hdl.Delay');
grid on;
