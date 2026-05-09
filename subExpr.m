function out = subExpr(a,b)
n = max(numel(a.coeff), numel(b.coeff));
a = padExpr(a,n);
b = padExpr(b,n);

out.const = a.const - b.const;
out.coeff = a.coeff - b.coeff;
end