function s = canonicalBoundString(bound, map, type)
termStrings = strings(1,numel(bound.terms));
for i = 1:numel(bound.terms)
    termStrings(i) = canonicalExprString(bound.terms(i), map);
end

termStrings = sort(termStrings);

if numel(termStrings) == 1
    s = char(termStrings(1));
else
    s = char(type + "{" + strjoin(termStrings,",") + "}");
end
end