function betaSet = collectOutgoingLabels(OMSC_list, tuple)

labels = {};

for j = 1:numel(OMSC_list)
    OMSC = OMSC_list{j};
    localVertex = tuple(j);

    for k = 1:numel(OMSC.E)
        if OMSC.E(k).source == localVertex
            labels{end+1} = OMSC.E(k).label; %#ok<AGROW>
        end
    end
end

betaSet = unique(labels, 'stable');

end