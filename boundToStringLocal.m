function s = boundToStringLocal(bound, varNames, type)
termStrings = strings(1,numel(bound.terms));

for i = 1:numel(bound.terms)
    termStrings(i) = exprToStringLocal(bound.terms(i), varNames);
end

if numel(termStrings) == 1
    s = char(termStrings(1));
else
    s = char(type + "{" + strjoin(termStrings,",") + "}");
end
end