function edgeIDs = outgoingEdgesWithLabel(OMSC, sourceVertex, beta)

edgeIDs = [];

for k = 1:numel(OMSC.E)
    if OMSC.E(k).source == sourceVertex && strcmp(OMSC.E(k).label, beta)
        edgeIDs(end+1) = k; %#ok<AGROW>
    end
end

end