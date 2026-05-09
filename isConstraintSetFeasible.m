function feasible = isConstraintSetFeasible(constraintStrings, tol)
% Convert constraint strings into linear inequalities/equalities and check LP feasibility.
%
% Supported constraint forms:
%
%   Delta_1_0 in [2, 5)
%   Delta_2_1 in [max{0,5-Delta_3_1},7-Delta_3_1)
%   Delta_5_3 in [1,min{9-Delta_3_3,5})
%   Delta_1_0 + Delta_2_1 = 12

if isempty(constraintStrings)
    feasible = true;
    return;
end

varNames = collectVariableNames(constraintStrings);
nVars = numel(varNames);

if nVars == 0
    feasible = true;
    return;
end

varMap = containers.Map();
for i = 1:nVars
    varMap(varNames{i}) = i;
end

A = [];
b = [];
Aeq = [];
beq = [];

for i = 1:numel(constraintStrings)

    str = constraintStrings{i};

    if isempty(str)
        continue;
    end

    [Ai, bi, Aeqi, beqi] = parseConstraintString(str, varMap, nVars, tol);

    A = [A; Ai]; %#ok<AGROW>
    b = [b; bi]; %#ok<AGROW>
    Aeq = [Aeq; Aeqi]; %#ok<AGROW>
    beq = [beq; beqi]; %#ok<AGROW>
end

f = zeros(nVars, 1);

opts = optimoptions('linprog', ...
    'Display', 'none', ...
    'Algorithm', 'dual-simplex');

try
    [~,~,exitflag] = linprog(f, A, b, Aeq, beq, [], [], opts);
catch ME
    error(['linprog is required for feasibility checking. ', ...
           'Original error: ', ME.message]);
end

feasible = (exitflag == 1 || exitflag == 2);

end