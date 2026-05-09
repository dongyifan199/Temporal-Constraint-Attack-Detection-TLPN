function key = makeOMSCGEdgeKey(sourceObs, targetObs, label, DeltaSum, CO)
if isstring(label)
    label = char(label);
end

coStr = strjoin(string(CO), ';');
key = sprintf('s%d-t%d-l%s-D%s-CO%s', ...
    sourceObs, targetObs, label, DeltaSum, coStr);
key = string(key);
end