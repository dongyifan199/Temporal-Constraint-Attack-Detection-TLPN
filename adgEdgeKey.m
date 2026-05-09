function key = adgEdgeKey(sourceID, beta, H, targetID)

hParts = strings(1, numel(H));

for k = 1:numel(H)
    hParts(k) = sprintf('a%d:e%d:D%s', ...
        H(k).attackIndex, H(k).OMSC_edge, H(k).Delta);
end

hStr = strjoin(hParts, ';');

key = sprintf('s%d-l%s-H%s-t%d', sourceID, beta, hStr, targetID);
key = string(key);

end