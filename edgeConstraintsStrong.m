function [Aedge, bedge, lbStr, ubStr] = edgeConstraintsStrong(Theta, firedT, En, DeltaExpr, nVars, varNames)
% Strong semantics:
%   Delta >= lower(firedT)
%   Delta < upper(s), for all s in En(M)
%
% Strict inequality is implemented numerically by a small tolerance.

tol = 1e-9;

Aedge = [];
bedge = [];

firedTheta = getTheta(Theta, firedT);

% Lower bound for fired transition.
lbStr = boundToString(firedTheta.lb, varNames, "max");

% Delta >= each lower term
for i = 1:numel(firedTheta.lb.terms)
    L = firedTheta.lb.terms(i);
    expr = subExpr(L, DeltaExpr);  % L - Delta <= 0
    Aedge = [Aedge; exprToRow(expr, nVars)]; %#ok<AGROW>
    bedge = [bedge; -expr.const]; %#ok<AGROW>
end

% Upper bound is min of all upper bounds of enabled transitions.
upperTerms = [];
for s = En
    th = getTheta(Theta, s);
    upperTerms = [upperTerms, th.ub.terms]; %#ok<AGROW>
end
ubBound = makeBound(upperTerms);
ubStr = boundToString(ubBound, varNames, "min");

% Delta < each upper term
for i = 1:numel(upperTerms)
    U = upperTerms(i);
    expr = subExpr(DeltaExpr, U);  % Delta - U <= -tol
    Aedge = [Aedge; exprToRow(expr, nVars)]; %#ok<AGROW>
    bedge = [bedge; -expr.const - tol]; %#ok<AGROW>
end
end