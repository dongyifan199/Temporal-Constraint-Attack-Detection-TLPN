function Theta = initialTheta(En, I)
Theta = struct([]);
for k = 1:numel(En)
    t = En(k);
    Theta(k).t = t;
    Theta(k).lb = makeBound(makeConst(I(t,1))); % lower bound
    Theta(k).ub = makeBound(makeConst(I(t,2))); % upper bound
end
end
