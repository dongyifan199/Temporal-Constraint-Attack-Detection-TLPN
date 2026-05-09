function s = canonicalExprString(expr, map)
keysList = cell2mat(keys(map));
n = numel(keysList);

coeff = zeros(1,n);
for k = 1:n
    oldIdx = keysList(k);
    newIdx = map(oldIdx);
    if oldIdx <= numel(expr.coeff)
        coeff(newIdx) = expr.coeff(oldIdx);
    end
end

parts = strings(0);

if abs(expr.const) > 1e-12 || all(abs(coeff) < 1e-12)
    parts(end+1) = string(num2str(roundSmallScalar(expr.const))); %#ok<AGROW>
end

for i = 1:n
    c = coeff(i);
    if abs(c) < 1e-12
        continue;
    end

    if abs(c-1) < 1e-12
        parts(end+1) = "x" + string(i); %#ok<AGROW>
    elseif abs(c+1) < 1e-12
        parts(end+1) = "-x" + string(i); %#ok<AGROW>
    else
        parts(end+1) = string(num2str(roundSmallScalar(c))) + "*x" + string(i); %#ok<AGROW>
    end
end

s = strjoin(parts, "+");
s = strrep(s, "+-", "-");
s = char(s);
end