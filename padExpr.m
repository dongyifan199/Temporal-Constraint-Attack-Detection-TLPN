function expr = padExpr(expr,n)
if numel(expr.coeff) < n
    expr.coeff = [expr.coeff, zeros(1,n-numel(expr.coeff))];
end
end