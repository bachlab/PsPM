function [n] = pspm_nan_percent(data)
n = sum(insnan(data))/numel(data);
end