function expr = makeVar(idx)
expr.const = 0;
expr.coeff = zeros(1,idx);
expr.coeff(idx) = 1;
end