function [DeltaSum, CO, Aall, ball] = aggregatePathInfo(MSCG, pathEdges)
% Aggregate Delta and CO along a path.

DeltaTerms = cell(1, numel(pathEdges));
CO = cell(1, numel(pathEdges));

maxCols = 0;
for k = 1:numel(pathEdges)
    e = MSCG.E(pathEdges(k));
    if isfield(e, 'A') && ~isempty(e.A)
        maxCols = max(maxCols, size(e.A, 2));
    end
end

Aall = zeros(0, maxCols);
ball = [];

for k = 1:numel(pathEdges)

    eid = pathEdges(k);
    e = MSCG.E(eid);

    DeltaTerms{k} = e.DeltaName;

    if isfield(e, 'DeltaLB') && isfield(e, 'DeltaUB')
        CO{k} = sprintf('%s in [%s, %s)', e.DeltaName, e.DeltaLB, e.DeltaUB);
    else
        CO{k} = sprintf('C(e%d)', eid);
    end

    if isfield(e, 'A') && ~isempty(e.A)
        Atemp = e.A;
        if size(Atemp, 2) < maxCols
            Atemp = [Atemp, zeros(size(Atemp, 1), maxCols - size(Atemp, 2))];
        end
        Aall = [Aall; Atemp]; %#ok<AGROW>
        ball = [ball; e.b]; %#ok<AGROW>
    end
end

DeltaSum = strjoin(DeltaTerms, ' + ');
end