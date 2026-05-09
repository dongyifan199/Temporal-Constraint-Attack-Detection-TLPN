function combos = cartesianProduct(optionLists)
% optionLists{j} is a row vector of choices.
% Return all combinations, one row per combination.

numLists = numel(optionLists);

combos = optionLists{1}(:);

for j = 2:numLists
    A = combos;
    B = optionLists{j}(:);

    newCombos = zeros(size(A,1) * numel(B), j);

    row = 1;
    for a = 1:size(A,1)
        for b = 1:numel(B)
            newCombos(row, 1:j-1) = A(a, :);
            newCombos(row, j) = B(b);
            row = row + 1;
        end
    end

    combos = newCombos;
end

end