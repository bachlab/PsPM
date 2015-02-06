function f_HR

xdot = [x(2); ...
        -alpha * (x(1) - v(1)) * (x(1) - v(2)) * x(2) - f * x(1) * (x(1) + d) * (x(1) + e)];