function used = variablesInTheta(Theta)
used = [];
for k = 1:numel(Theta)
    used = union(used, variablesInBound(Theta(k).lb));
    used = union(used, variablesInBound(Theta(k).ub));
end
end

function used = variablesInBound(bound)
used = [];
for i = 1:numel(bound.terms)
    used = union(used, find(abs(bound.terms(i).coeff) > 1e-12));
end
end