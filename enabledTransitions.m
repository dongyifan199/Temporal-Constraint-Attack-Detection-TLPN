function En = enabledTransitions(M, Pre)
nT = size(Pre,2);
En = [];
for t = 1:nT
    if all(M >= Pre(:,t))
        En(end+1) = t; %#ok<AGROW>
    end
end
end

