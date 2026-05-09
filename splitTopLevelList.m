function list = splitTopLevelList(str)

list = {};
depth = 0;
startIdx = 1;

for i = 1:length(str)
    ch = str(i);

    if ch == '{'
        depth = depth + 1;
    elseif ch == '}'
        depth = depth - 1;
    elseif ch == ',' && depth == 0
        list{end+1} = str(startIdx:i-1); %#ok<AGROW>
        startIdx = i + 1;
    end
end

list{end+1} = str(startIdx:end);

end