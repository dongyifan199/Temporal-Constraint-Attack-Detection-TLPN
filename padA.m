function A2 = padA(A, nVars)
if isempty(A)
    A2 = zeros(0, nVars);
    return;
end

if size(A,2) < nVars
    A2 = [A, zeros(size(A,1), nVars-size(A,2))];
else
    A2 = A;
end
end