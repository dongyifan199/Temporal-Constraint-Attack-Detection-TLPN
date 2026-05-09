function s = appendDeltaExpr(oldExpr, newExpr)

if isempty(oldExpr)
    s = newExpr;
else
    s = [oldExpr, ' + ', newExpr];
end

end