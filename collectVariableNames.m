function varNames = collectVariableNames(constraintStrings)

allVars = {};

pattern = '[A-Za-z]+_\d+_\d+';

for i = 1:numel(constraintStrings)
    tokens = regexp(constraintStrings{i}, pattern, 'match');
    for k = 1:numel(tokens)
        allVars{end+1} = tokens{k}; %#ok<AGROW>
    end
end

varNames = unique(allVars, 'stable');

end