function x = roundSmallScalar(x)
if abs(x) < 1e-10
    x = 0;
end
end