function [A, b, Aeq, beq] = parseConstraintString(str, varMap, nVars, tol)

A = [];
b = [];
Aeq = [];
beq = [];

str = char(str);
str = strtrim(str);
str = strrep(str, ' ', '');

% Interval constraint:
%   X in [LB,UB)
if contains(str, 'in[')

    parts = split(str, 'in[');
    varName = char(parts{1});

    right = char(parts{2});

    % Remove final ')' or ']'
    if right(end) == ')' || right(end) == ']'
        right = right(1:end-1);
    end

    % Split LB and UB at top-level comma.
    [lbStr, ubStr] = splitTopLevelComma(right);

    lowerTerms = expandMaxMinBound(lbStr, 'max');
    upperTerms = expandMaxMinBound(ubStr, 'min');

    % lower <= X
    for k = 1:numel(lowerTerms)
        L = parseLinearExpr(lowerTerms{k}, varMap, nVars);
        X = parseLinearExpr(varName, varMap, nVars);

        expr = subtractExpr(L, X);  % L - X <= 0

        A = [A; expr.coeff]; %#ok<AGROW>
        b = [b; -expr.const]; %#ok<AGROW>
    end

    % X < upper
    for k = 1:numel(upperTerms)
        U = parseLinearExpr(upperTerms{k}, varMap, nVars);
        X = parseLinearExpr(varName, varMap, nVars);

        expr = subtractExpr(X, U);  % X - U <= -tol

        A = [A; expr.coeff]; %#ok<AGROW>
        b = [b; -expr.const - tol]; %#ok<AGROW>
    end

    return;
end

% Equality constraint:
%   expr = constant
if contains(str, '=')

    idx = strfind(str, '=');
    lhs = str(1:idx(1)-1);
    rhs = str(idx(1)+1:end);

    L = parseLinearExpr(lhs, varMap, nVars);
    R = parseLinearExpr(rhs, varMap, nVars);

    expr = subtractExpr(L, R); % L - R = 0

    Aeq = expr.coeff;
    beq = -expr.const;

    return;
end

error('Unsupported constraint format: %s', str);

end
