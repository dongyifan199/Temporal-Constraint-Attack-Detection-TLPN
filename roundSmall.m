function x = roundSmall(x)
x(abs(x) < 1e-10) = 0;
end