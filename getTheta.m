function th = getTheta(Theta, t)
idx = find([Theta.t] == t, 1);
if isempty(idx)
    error('Transition t%d is not found in Theta.', t);
end
th = Theta(idx);
end