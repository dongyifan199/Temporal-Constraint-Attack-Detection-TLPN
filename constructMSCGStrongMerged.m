function MSCG = constructMSCGStrongMerged(G, maxNodes)
% constructMSCGStrongMerged
% Construct the Modified State Class Graph (MSCG) of a TLPN under strong semantics.
%
% Input:
%   G.Pre      : m x n pre-incidence matrix
%   G.Post     : m x n post-incidence matrix
%   G.M0       : m x 1 initial marking
%   G.labels   : 1 x n cell array, e.g., {'eps','a','eps','b','b'}
%   G.I        : n x 2 firing intervals, G.I(t,:) = [lt, ut]
%
% Output:
%   MSCG.V     : vertices
%   MSCG.E     : edges
%   MSCG.v0    : initial vertex id
%
% Each vertex v is a state class (M,Theta), with additional linear
% constraints on symbolic Delta variables for feasibility checking.
%
% Each edge e is of the form:
%   e = (source, transition, label, Delta, target)

if nargin < 2
    maxNodes = 500;
end

Pre  = G.Pre;
Post = G.Post;
M0   = G.M0(:);
I    = G.I;
labels = G.labels;
C = Post - Pre;

% Global variable names for all symbolic Delta variables.
varNames = {};

% ---------- Initial vertex ----------
En0 = enabledTransitions(M0, Pre);
Theta0 = initialTheta(En0, I);

V = struct([]);
E = struct([]);

V(1).id = 1;
V(1).M = M0;
V(1).En = En0;
V(1).Theta = Theta0;
V(1).A = [];
V(1).b = [];
V(1).key = canonicalVertexKey(M0, Theta0, [], [], varNames);

queue = 1;
head = 1;

while head <= numel(queue)
    vid = queue(head);
    head = head + 1;

    v = V(vid);
    M = v.M;
    En = v.En;

    for tt = En

        % Add a new Delta variable for this candidate edge.
        %newVarName = sprintf('D_%d_%d', tt, vid);
        sourceVertexIndex = vid - 1;
        newVarName = sprintf('Delta_%d_%d', tt, sourceVertexIndex);
        varNames{end+1} = newVarName; %#ok<AGROW>
        deltaIdx = numel(varNames);
        DeltaExpr = makeVar(deltaIdx);

        % Strong-semantics firing constraints for Delta.
        [Aedge, bedge, lbStr, ubStr] = edgeConstraintsStrong( ...
            v.Theta, tt, En, DeltaExpr, numel(varNames), varNames);

        % Accumulate constraints.
        Acand = padA(v.A, numel(varNames));
        bcand = v.b;

        Acand = [Acand; Aedge];
        bcand = [bcand; bedge];

        % Feasibility check.
        if ~isFeasibleLP(Acand, bcand, numel(varNames))
            varNames(end) = [];
            continue;
        end

        % Fire transition tt.
        Mprime = M + C(:,tt);

        % Enabled transitions at successor marking.
        EnPrime = enabledTransitions(Mprime, Pre);

        % Intermediate marking after removing consumed tokens.
        Mmid = M - Pre(:,tt);

        % Newly enabled transitions under enabling memory policy.
        NewSet = newlyEnabled(tt, EnPrime, Mmid, Pre);

        % Compute successor state class.
        ThetaPrime = successorTheta(v.Theta, EnPrime, NewSet, DeltaExpr, I);

        % Keep only constraints involving variables that still appear in ThetaPrime.
        usedVars = variablesInTheta(ThetaPrime);
        [Ared, bred] = keepRelevantConstraints(Acand, bcand, usedVars);

        % Generate canonical key for merging.
        keyPrime = canonicalVertexKey(Mprime, ThetaPrime, Ared, bred, varNames);

        % Find equivalent existing vertex.
        vprimeID = findVertex(V, keyPrime);

        if vprimeID == 0
            if numel(V) >= maxNodes
                error('Maximum number of nodes reached. The graph may be too large.');
            end

            vprimeID = numel(V) + 1;
            V(vprimeID).id = vprimeID;
            V(vprimeID).M = Mprime;
            V(vprimeID).En = EnPrime;
            V(vprimeID).Theta = ThetaPrime;
            V(vprimeID).A = Ared;
            V(vprimeID).b = bred;
            V(vprimeID).key = keyPrime;

            queue(end+1) = vprimeID; %#ok<AGROW>
        end

        % Store edge.
        eid = numel(E) + 1;
        E(eid).id = eid;
        E(eid).source = vid;
        E(eid).target = vprimeID;
        E(eid).transition = tt;
        E(eid).label = labels{tt};
        E(eid).Delta = DeltaExpr;
        E(eid).DeltaName = newVarName;
        E(eid).DeltaLB = lbStr;
        E(eid).DeltaUB = ubStr;
        E(eid).A = Aedge;
        E(eid).b = bedge;
    end
end

MSCG.V = V;
MSCG.E = E;
MSCG.v0 = 1;
MSCG.varNames = varNames;

end
