function edgeIDs = findOutgoingADGEdges(ADG, sourceV, label)

edgeIDs = [];

for k = 1:numel(ADG.E)
    if ADG.E(k).source == sourceV && strcmp(ADG.E(k).label, label)
        edgeIDs(end+1) = k; %#ok<AGROW>
    end
end

end