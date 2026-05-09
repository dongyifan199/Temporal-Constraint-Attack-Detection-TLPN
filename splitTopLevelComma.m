function [left, right] = splitTopLevelComma(str)

depth = 0;

for i = 1:length(str)
    ch = str(i);

    if ch == '{'
        depth = depth + 1;
    elseif ch == '}'
        depth = depth - 1;
    elseif ch == ',' && depth == 0
        left = str(1:i-1);
        right = str(i+1:end);
        return;
    end
end

error('Cannot split interval bound: %s', str);

end