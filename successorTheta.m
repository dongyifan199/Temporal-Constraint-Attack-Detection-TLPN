function ThetaPrime = successorTheta(Theta, EnPrime, NewSet, DeltaExpr, I)
ThetaPrime = struct([]);

for k = 1:numel(EnPrime)
    t = EnPrime(k);

    if ismember(t, NewSet)
        % Newly enabled transition: reset local clock.
        lb = makeBound(makeConst(I(t,1)));
        ub = makeBound(makeConst(I(t,2)));
    else
        % Previously enabled transition: remaining firing time decreases by Delta.
        old = getTheta(Theta, t);

        % lb' = max{0, lb - Delta}
        lbTerms = old.lb.terms;
        for i = 1:numel(lbTerms)
            lbTerms(i) = subExpr(lbTerms(i), DeltaExpr);
        end
        lbTerms(end+1) = makeConst(0); %#ok<AGROW>
        lb = makeBound(lbTerms);

        % ub' = ub - Delta
        ubTerms = old.ub.terms;
        for i = 1:numel(ubTerms)
            ubTerms(i) = subExpr(ubTerms(i), DeltaExpr);
        end
        ub = makeBound(ubTerms);
    end

    ThetaPrime(k).t = t;
    ThetaPrime(k).lb = lb;
    ThetaPrime(k).ub = ub;
end
end