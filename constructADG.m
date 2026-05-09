function ADG = constructADG(OMSC_list)
% constructADG
% Construct the Attack Detection Graph (ADG) from a set of OMSCGs.
%
% Input:
%   OMSC_list : cell array of OMSCGs
%               OMSC_list{j} is the OMSCG under attack hypothesis alpha_{j-1}
%
% Output:
%   ADG.V     : vertices of the ADG
%   ADG.E     : edges of the ADG
%   ADG.v0    : initial vertex index
%
% An ADG vertex is a tuple
%   v = (v_0, v_1, ..., v_h),
% where v_j is a vertex of OMSC_list{j+1}.
%
% An ADG edge is of the form
%   e = (v, beta, H, v')
%
% where H collects all timing information from component OMSCG edges
% with the same observable label beta.

if ~iscell(OMSC_list)
    error('Input OMSC_list must be a cell array, e.g., {OMSC0, OMSC1, ...}.');
end

numModels = numel(OMSC_list);

% ------------------------------------------------------------
% Initial ADG vertex
% ------------------------------------------------------------

initTuple = zeros(1, numModels);
for j = 1:numModels
    initTuple(j) = OMSC_list{j}.v0;
end

V = struct([]);
E = struct([]);

V(1).id = 1;
V(1).tuple = initTuple;
V(1).key = tupleKey(initTuple);

queue = 1;
head = 1;

edgeKeys = strings(0);

% ------------------------------------------------------------
% BFS construction
% ------------------------------------------------------------

while head <= numel(queue)

    currentID = queue(head);
    head = head + 1;

    currentTuple = V(currentID).tuple;

    % Collect all observable labels enabled from current tuple.
    betaSet = collectOutgoingLabels(OMSC_list, currentTuple);

    for b = 1:numel(betaSet)

        beta = betaSet{b};

        % For each component OMSCG, find outgoing edges labeled beta.
        optionLists = cell(1, numModels);

        for j = 1:numModels
            OMSC = OMSC_list{j};
            localVertex = currentTuple(j);

            edgeIDs = outgoingEdgesWithLabel(OMSC, localVertex, beta);

            if isempty(edgeIDs)
                % No beta-labeled edge in this component:
                % this component stays unchanged.
                optionLists{j} = 0;
            else
                % One or more beta-labeled edges exist:
                % each of them is a possible local evolution.
                optionLists{j} = edgeIDs;
            end
        end

        % Cartesian product of local choices.
        combos = cartesianProduct(optionLists);

        for c = 1:size(combos, 1)

            combo = combos(c, :);

            % Build successor tuple and H.
            nextTuple = currentTuple;
            H = struct([]);

            for j = 1:numModels

                edgeID = combo(j);

                if edgeID == 0
                    % Component j does not move.
                    nextTuple(j) = currentTuple(j);
                else
                    % Component j follows a beta-labeled edge.
                    OMSC = OMSC_list{j};
                    oe = OMSC.E(edgeID);

                    nextTuple(j) = oe.target;

                    hID = numel(H) + 1;
                    H(hID).attackIndex = j - 1;     % alpha_{j-1}
                    H(hID).component = j;            % MATLAB index
                    H(hID).OMSC_edge = edgeID;
                    H(hID).source = oe.source;
                    H(hID).target = oe.target;
                    H(hID).label = oe.label;
                    H(hID).Delta = oe.Delta;
                    H(hID).CO = oe.CO;

                    if isfield(oe, 'A')
                        H(hID).A = oe.A;
                    else
                        H(hID).A = [];
                    end

                    if isfield(oe, 'b')
                        H(hID).b = oe.b;
                    else
                        H(hID).b = [];
                    end

                    if isfield(oe, 'pathEdges')
                        H(hID).pathEdges = oe.pathEdges;
                    else
                        H(hID).pathEdges = [];
                    end
                end
            end

            % Add or find successor ADG vertex.
            nextKey = tupleKey(nextTuple);
            nextID = findADGVertex(V, nextKey);

            if nextID == 0
                nextID = numel(V) + 1;
                V(nextID).id = nextID;
                V(nextID).tuple = nextTuple;
                V(nextID).key = nextKey;

                queue(end+1) = nextID; %#ok<AGROW>
            end

            % Avoid exact duplicate ADG edges.
            eKey = adgEdgeKey(currentID, beta, H, nextID);

            if any(edgeKeys == eKey)
                continue;
            end

            edgeKeys(end+1) = eKey; %#ok<AGROW>

            % Store ADG edge.
            eid = numel(E) + 1;
            E(eid).id = eid;
            E(eid).source = currentID;
            E(eid).target = nextID;
            E(eid).sourceTuple = currentTuple;
            E(eid).targetTuple = nextTuple;
            E(eid).label = beta;
            E(eid).H = H;
            E(eid).localChoices = combo;
        end
    end
end

ADG.V = V;
ADG.E = E;
ADG.v0 = 1;
ADG.numModels = numModels;
ADG.OMSC_list = OMSC_list;

end
