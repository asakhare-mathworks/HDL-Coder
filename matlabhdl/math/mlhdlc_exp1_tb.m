%   Copyright 2024 The MathWorks, Inc.
function mlhdlc_exp1_tb()
    % Define word length and fraction length
    word_length = 16;
    fraction_length = 12;
    nt = numerictype(1, word_length, fraction_length);
    inputrange = double(nt.range);
    % Generate 5000 random values in the range 
    num_tests = 5000;
    rng(0, 'twister');
    random_values = (rand(num_tests, 1) - 0.5) * (inputrange(2) - inputrange(1)); 
    % Initialize arrays to store results
    fixed_point_results = zeros(num_tests, 1);
    floating_point_results = zeros(num_tests, 1);

    % Calculate exponential for each random value
    for i = 1:num_tests
        x  = random_values(i);
        x_fp = fi(x, nt);
        % Compute fixed-point exponential
        fixed_point_results(i) = mlhdlc_exp1(x_fp);
        % Compute floating-point exponential (golden value)
        floating_point_results(i) = exp(x);
    end

    % Calculate errors
    errors = abs(double(fixed_point_results) - floating_point_results);

    % Plot the results
    figure;
    
    % Floating-point results
    subplot(3, 1, 1);
    plot(random_values, floating_point_results, 'b.', 'DisplayName', 'Floating-point (Golden)');
    xlabel('Input Value');
    ylabel('Exponential Result');
    title('Floating-point Exponential Results');
    legend show;
    grid on;

    % Fixed-point results
    subplot(3, 1, 2);
    plot(random_values, fixed_point_results, 'r.', 'DisplayName', 'Fixed-point');
    xlabel('Input Value');
    ylabel('Exponential Result');
    title('Fixed-point Exponential Results');
    legend show;
    grid on;

    % Absolute error
    subplot(3, 1, 3);
    plot(random_values, errors, 'k.', 'DisplayName', 'Absolute Error');
    xlabel('Input Value');
    ylabel('Absolute Error');
    title('Absolute Error between Fixed-point and Floating-point Results');
    legend show;
    grid on;

    % Compute and display the mean absolute error
    mean_absolute_error = mean(errors);
    fprintf('Mean Absolute Error over 5000 tests: %.5f\n', mean_absolute_error);
end