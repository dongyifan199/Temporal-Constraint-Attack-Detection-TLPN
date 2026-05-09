function tf = isEpsilonLabel(label, epsLabels)
if isstring(label)
    label = char(label);
end

tf = false;
for i = 1:numel(epsLabels)
    if strcmp(label, epsLabels{i})
        tf = true;
        return;
    end
end
end