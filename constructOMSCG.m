function OMSC = constructOMSCG(MSCG, epsLabels)
% constructOMSCG
% Construct the Observable Modified State Class Graph (OMSCG)
% from a given Modified State Class Graph (MSCG).
%
% Input:
%   MSCG      : output of constructMSCGStrongMerged
%   epsLabels : optional cell array of labels regarded as epsilon
%               default: {'eps','epsilon','\epsilon','ε'}
%
% Output:
%   OMSC.V        : observable vertices
%   OMSC.E        : observable edges
%   OMSC.v0       : initial observable vertex in OMSC index
%   OMSC.origV    : original MSCG vertex indices corresponding to OMSC.V
%
% Each OMSC edge eo stores:
%   eo.source       : source vertex index in OMSC
%   eo.target       : target vertex index in OMSC
%   eo.sourceOrig   : source vertex index in MSCG
%   eo.targetOrig   : target vertex index in MSCG
%   eo.label        : observable label beta
%   eo.Delta        : accumulated Delta string
%   eo.CO           : cell array of timing constraints C(e_i)
%   eo.pathEdges    : MSCG edge ids forming the unobservable-label path
%   eo.pathVertices : MSCG vertex ids along the path
%   eo.A, eo.b      : aggregated linear constraints along the path

if nargin < 2
    epsLabels = {'eps','epsilon','\epsilon','ε'};
end

% ------------------------------------------------------------
% Step 1: Identify observable vertices V_o.
% v0 is defined to be observable.
% A vertex v' is observable if it is the target of an observable edge.
% ------------------------------------------------------------

numV = numel(MSCG.V);
numE = numel(MSCG.E);

observableOrig = false(1, numV);
observableOrig(MSCG.v0) = true;

for k = 1:numE
    if ~isEpsilonLabel(MSCG.E(k).label, epsLabels)
        observableOrig(MSCG.E(k).target) = true;
    end
end

origV = find(observableOrig);

% Map original MSCG vertex index -> OMSC vertex index.
origToObs = zeros(1, numV);
for i = 1:numel(origV)
    origToObs(origV(i)) = i;
end

% Store observable vertices.
OV = struct([]);
for i = 1:numel(origV)
    oldID = origV(i);
    OV(i).id = i;
    OV(i).origID = oldID;
    OV(i).M = MSCG.V(oldID).M;
    OV(i).En = MSCG.V(oldID).En;
    OV(i).Theta = MSCG.V(oldID).Theta;
end

% ------------------------------------------------------------
% Step 2: Build adjacency list of MSCG.
% ------------------------------------------------------------

outEdges = cell(1, numV);
for k = 1:numE
    s = MSCG.E(k).source;
    outEdges{s}(end+1) = k; %#ok<AGROW>
end

% ------------------------------------------------------------
% Step 3: For each observable vertex, enumerate all
% unobservable-label paths ending with one observable edge.
% ------------------------------------------------------------

OE = struct([]);
edgeKeys = strings(0);

for oi = 1:numel(origV)

    startOrig = origV(oi);

    % DFS stack element:
    % current vertex, path edge list, path vertex list.
    stack = {};
    stack{end+1} = struct( ...
        'current', startOrig, ...
        'pathEdges', [], ...
        'pathVertices', startOrig, ...
        'visited', startOrig); %#ok<AGROW>

    while ~isempty(stack)

        item = stack{end};
        stack(end) = [];

        curr = item.current;

        for idx = 1:numel(outEdges{curr})

            eid = outEdges{curr}(idx);
            e = MSCG.E(eid);

            newPathEdges = [item.pathEdges, eid];
            newPathVertices = [item.pathVertices, e.target];

            if isEpsilonLabel(e.label, epsLabels)
                % Continue along epsilon edges.
                % Since Pi_ul is finite under Assumption A2, this is safe.
                % The visited check is added only as a protection.
                if ismember(e.target, item.visited)
                    continue;
                end

                stack{end+1} = struct( ...
                    'current', e.target, ...
                    'pathEdges', newPathEdges, ...
                    'pathVertices', newPathVertices, ...
                    'visited', [item.visited, e.target]); %#ok<AGROW>

            else
                % This is the final observable edge.
                targetOrig = e.target;

                if origToObs(targetOrig) == 0
                    error('Internal error: target of an observable MSCG edge should be observable.');
                end

                sourceObs = oi;
                targetObs = origToObs(targetOrig);

                [DeltaSum, CO, Aall, ball] = aggregatePathInfo(MSCG, newPathEdges);

                % Avoid exact duplicate OMSC edges.
                key = makeOMSCGEdgeKey(sourceObs, targetObs, e.label, DeltaSum, CO);

                if any(edgeKeys == key)
                    continue;
                end

                edgeKeys(end+1) = key; %#ok<AGROW>

                newID = numel(OE) + 1;
                OE(newID).id = newID;
                OE(newID).source = sourceObs;
                OE(newID).target = targetObs;
                OE(newID).sourceOrig = startOrig;
                OE(newID).targetOrig = targetOrig;
                OE(newID).label = e.label;
                OE(newID).Delta = DeltaSum;
                OE(newID).CO = CO;
                OE(newID).A = Aall;
                OE(newID).b = ball;
                OE(newID).pathEdges = newPathEdges;
                OE(newID).pathVertices = newPathVertices;
            end
        end
    end
end

% ------------------------------------------------------------
% Output.
% ------------------------------------------------------------

OMSC.V = OV;
OMSC.E = OE;
OMSC.v0 = origToObs(MSCG.v0);
OMSC.origV = origV;
OMSC.origToObs = origToObs;

end