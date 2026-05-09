function s = exprToString(expr, varNames)
expr = padExpr(expr, numel(varNames));

parts = strings(0);

if abs(expr.const) > 1e-12 || all(abs(expr.coeff) < 1e-12)
    parts(end+1) = string(num2str(roundSmallScalar(expr.const))); %#ok<AGROW>
end

for i = 1:numel(expr.coeff)
    c = expr.coeff(i);
    if abs(c) < 1e-12
        continue;
    end

    if abs(c-1) < 1e-12
        parts(end+1) = string(varNames{i}); %#ok<AGROW>
    elseif abs(c+1) < 1e-12
        parts(end+1) = "-" + string(varNames{i}); %#ok<AGROW>
    else
        parts(end+1) = string(num2str(roundSmallScalar(c))) + "*" + string(varNames{i}); %#ok<AGROW>
    end
end

s = strjoin(parts,"+");
s = strrep(s,"+-","-");
s = char(s);
end