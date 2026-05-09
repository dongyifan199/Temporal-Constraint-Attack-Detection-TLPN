function key = canonicalVertexKey(M, Theta, A, b, varNames)
% Canonical key up to variable renaming.
% This allows two state classes with the same structure but different Delta
% variable names to be merged.

usedVars = variablesInTheta(Theta);

% Also include variables appearing in remaining constraints.
if ~isempty(A)
    for i = 1:size(A,1)
        usedVars = union(usedVars, find(abs(A(i,:)) > 1e-12));
    end
end

usedVars = sort(usedVars);

% Map old variable indices to canonical indices x1,x2,...
map = containers.Map('KeyType','double','ValueType','double');
for k = 1:numel(usedVars)
    map(usedVars(k)) = k;
end

thetaParts = strings(1,numel(Theta));
for k = 1:numel(Theta)
    th = Theta(k);
    lbStr = canonicalBoundString(th.lb, map, "max");
    ubStr = canonicalBoundString(th.ub, map, "min");
    thetaParts(k) = sprintf('t%d:[%s,%s]', th.t, lbStr, ubStr);
end

constraintParts = strings(0);

if ~isempty(A)
    A = padA(A, numel(varNames));

    for i = 1:size(A,1)
        row = A(i,:);
        if all(abs(row) < 1e-12)
            continue;
        end

        coeff = zeros(1,numel(usedVars));
        for k = 1:numel(usedVars)
            coeff(k) = row(usedVars(k));
        end

        constraintParts(end+1) = sprintf('%s<=%.10g', ...
            mat2str(roundSmall(coeff)), roundSmallScalar(b(i))); %#ok<AGROW>
    end

    constraintParts = sort(constraintParts);
end

key = sprintf('M=%s|Theta=%s|C=%s', ...
    mat2str(M(:)'), ...
    strjoin(thetaParts,';'), ...
    strjoin(constraintParts,';'));
end