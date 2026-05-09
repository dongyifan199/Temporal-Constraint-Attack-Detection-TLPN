function key = tupleKey(tuple)

parts = strings(1, numel(tuple));

for j = 1:numel(tuple)
    % Displayed vertex index is local index minus 1.
    parts(j) = sprintf('v%d', tuple(j)-1);
end

key = strjoin(parts, ',');

end
