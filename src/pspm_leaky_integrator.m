function filteredData = pspm_leaky_integrator(data, tau)
    % pspm_leaky_integrator applies a leaky integrator filter to the input data
    %
    % Arguments:
    %   data: A numerical vector representing the input signal to be filtered.
    %   tau: The time constant of the leaky integrator, representing the 
    %        leak rate.
    %
    % Returns:
    %   filteredData: The filtered signal, of the same size as the input data, 
    %                 processed by the leaky integrator.
    
    % Initialize the filteredData vector with the same size as input data
    filteredData = zeros(size(data));
    % Start with the first value of the input data
    filteredData(1) = data(1);
    % Apply the leaky integrator formula to each data point
    for i = 2:length(data)
        filteredData(i) = filteredData(i - 1) + (data(i) - filteredData(i - 1)) / tau;
    end
end
