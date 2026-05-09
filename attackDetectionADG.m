function [A, DET] = attackDetectionADG(ADG, w_a, options)
% attackDetectionADG
% Attack detection based on the ADG.
%
% Input:
%   ADG:
%       output of constructADG
%
%   w_a:
%       attacked timed observation.
%
%       Recommended format:
%           w_a.labels = {'a','b'};
%           w_a.times  = [12,17];
%
%       It also supports:
%           w_a = { {'a',12}, {'b',17} };
%
%   options:
%       options.tol      : tolerance for strict inequalities, default 1e-9
%       options.verbose  : true/false, default false
%
% Output:
%   A:
%       row vector of possible attack indices, e.g., [1] means {alpha_1}
%
%   DET:
%       detailed information of the detection process
%
% Candidate format:
%   cand.v          : current ADG vertex index
%   cand.A          : active attack hypotheses, internally 1-based
%   cand.Phi        : cell array, Phi{j} stores constraint strings of alpha_{j-1}
%   cand.DeltaSum   : cell array, cumulative Delta expression of alpha_{j-1}

if nargin < 3
    options = struct();
end

if ~isfield(options, 'tol')
    options.tol = 1e-9;
end

if ~isfield(options, 'verbose')
    options.verbose = false;
end

[betaSeq, tauSeq] = normalizeObservation(w_a);
s = numel(betaSeq);

numModels = ADG.numModels;   % h+1
attackInternal = 1:numModels;

% ------------------------------------------------------------
% Initialization
% ------------------------------------------------------------

Phi0 = cell(1, numModels);
DeltaSum0 = cell(1, numModels);

for j = 1:numModels
    Phi0{j} = {};
    DeltaSum0{j} = '';
end

S = {};
S{1} = struct( ...
    'v', ADG.v0, ...
    'A', attackInternal, ...
    'Phi', {Phi0}, ...
    'DeltaSum', {DeltaSum0});

S_history = cell(1, s+1);
S_history{1} = S;

% ------------------------------------------------------------
% Main loop
% ------------------------------------------------------------

for i = 1:s

    beta_i = betaSeq{i};
    tau_i = tauSeq(i);

    S_next = {};

    if options.verbose
        fprintf('\n=== Step %d: observation (%s, %.10g) ===\n', ...
            i, beta_i, tau_i);
    end

    for cID = 1:numel(S)

        cand = S{cID};

        % Find all ADG edges leaving cand.v with label beta_i.
        edgeIDs = findOutgoingADGEdges(ADG, cand.v, beta_i);

        for ee = edgeIDs

            edge = ADG.E(ee);

            A_new = [];
            Phi_new = cand.Phi;
            DeltaSum_new = cand.DeltaSum;

            % Check each attack hypothesis.
            for j = 1:numModels

                % Algorithm line 12--13
                if ~ismember(j, cand.A)
                    continue;
                end

                % Algorithm line 14--15:
                % find timing information of alpha_{j-1} in H.
                hk = findHByAttack(edge.H, j);

                if isempty(hk)
                    continue;
                end

                % Accumulate timing constraints.
                oldPhi = cand.Phi{j};

                if isfield(hk, 'CO') && ~isempty(hk.CO)
                    newCO = hk.CO(:);
                else
                    newCO = {};
                end

                % Accumulate Delta expression:
                % sum_{k=1}^{i} Delta_{eps beta_k}^{j}
                newDeltaSum = appendDeltaExpr(cand.DeltaSum{j}, hk.Delta);

                equalityStr = sprintf('%s = %.15g', newDeltaSum, tau_i);

                Phi_candidate = [oldPhi(:); newCO(:); {equalityStr}];

                % Feasibility check.
                feasible = isConstraintSetFeasible(Phi_candidate, options.tol);

                if options.verbose
                    fprintf('  Edge e%d, alpha_%d: ', ee, j-1);
                    if feasible
                        fprintf('feasible\n');
                    else
                        fprintf('infeasible\n');
                    end
                end

                if feasible
                    A_new(end+1) = j; %#ok<AGROW>
                    Phi_new{j} = Phi_candidate;
                    DeltaSum_new{j} = newDeltaSum;
                end
            end

            % Path-level pruning.
            if ~isempty(A_new)
                newCand = struct( ...
                    'v', edge.target, ...
                    'A', unique(A_new), ...
                    'Phi', {Phi_new}, ...
                    'DeltaSum', {DeltaSum_new});

                S_next{end+1} = newCand; %#ok<AGROW>
            end
        end
    end

    S = S_next;
    S_history{i+1} = S;

    if options.verbose
        fprintf('Number of candidates after step %d: %d\n', i, numel(S));
    end
end

% ------------------------------------------------------------
% Output
% ------------------------------------------------------------

A_internal = [];

for cID = 1:numel(S)
    A_internal = union(A_internal, S{cID}.A);
end

% Convert internal 1-based indices to paper notation alpha_0,...,alpha_h.
A = A_internal - 1;

DET.finalCandidates = S;
DET.S_history = S_history;
DET.attackInternal = A_internal;
DET.attackIndices = A;
DET.betaSeq = betaSeq;
DET.tauSeq = tauSeq;

end
