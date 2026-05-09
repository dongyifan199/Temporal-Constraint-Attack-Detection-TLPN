function NewSet = newlyEnabled(firedT, EnPrime, Mmid, Pre)
NewSet = [];

if ismember(firedT, EnPrime)
    NewSet(end+1) = firedT;
end

for q = EnPrime
    if ~all(Mmid >= Pre(:,q))
        NewSet(end+1) = q; %#ok<AGROW>
    end
end

NewSet = unique(NewSet);
end
