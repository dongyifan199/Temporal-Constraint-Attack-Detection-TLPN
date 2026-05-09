function id = findADGVertex(V, key)

id = 0;

for i = 1:numel(V)
    if strcmp(V(i).key, key)
        id = i;
        return;
    end
end

end