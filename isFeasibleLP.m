function feasible = isFeasibleLP(A, b, nVars)
if isempty(A)
    feasible = true;
    return;
end

A = padA(A, nVars);
f = zeros(nVars,1);

opts = optimoptions('linprog', ...
    'Display', 'none', ...
    'Algorithm', 'dual-simplex');

try
    [~,~,exitflag] = linprog(f, A, b, [], [], [], [], opts);
catch
    error('linprog is required. Please install MATLAB Optimization Toolbox.');
end

feasible = (exitflag == 1 || exitflag == 2);
end