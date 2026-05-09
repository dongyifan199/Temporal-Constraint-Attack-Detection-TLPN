function [Ared, bred] = keepRelevantConstraints(A, b, usedVars)
if isempty(A)
    Ared = A;
    bred = b;
    return;
end

if isempty(usedVars)
    Ared = [];
    bred = [];
    return;
end

keep = false(size(A,1),1);
for i = 1:size(A,1)
    nz = find(abs(A(i,:)) > 1e-12);
    if any(ismember(nz, usedVars))
        keep(i) = true;
    end
end

Ared = A(keep,:);
bred = b(keep);
end