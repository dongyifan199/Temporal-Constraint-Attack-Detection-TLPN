function row = exprToRow(expr,nVars)
expr = padExpr(expr,nVars);
row = expr.coeff;
end