clear; clc;

%% ============================================================
% Build wafer TLPN benchmark with n = 2
%% ============================================================

n = 2;

[G_list, attackNames, meta] = makeWaferTLPNBenchmark_FigModel(n);

fprintf('Wafer TLPN benchmark with n = %d\n', n);
fprintf('|P| = %d, |T| = %d\n', meta.numPlaces, meta.numTransitions);
fprintf('%s\n', meta.initialMarkingDescription);

fprintf('\nTransition labels and nominal intervals:\n');
for t = 1:meta.numTransitions
    fprintf('%s: label = %s, I0 = [%g,%g]\n', ...
        meta.transitionNames{t}, ...
        meta.labels{t}, ...
        G_list{1}.I(t,1), ...
        G_list{1}.I(t,2));
end

fprintf('\nObservable transitions:\n');
disp(meta.observableTransitions')

%% ============================================================
% Construct MSCGs and OMSCGs for all attack hypotheses
%% ============================================================

numModels = numel(G_list);

MSCG_list = cell(1,numModels);
OMSC_list = cell(1,numModels);

for i = 1:numModels

    fprintf('\nConstructing MSCG and OMSCG for %s\n', attackNames{i});

    maxNodes = 3000;

    MSCG_list{i} = constructMSCGStrongMerged(G_list{i}, maxNodes);
    OMSC_list{i} = constructOMSCG(MSCG_list{i});

    fprintf('    MSCG:  |V| = %d, |E| = %d\n', ...
        numel(MSCG_list{i}.V), numel(MSCG_list{i}.E));

    fprintf('    OMSCG: |V_o| = %d, |E_o| = %d\n', ...
        numel(OMSC_list{i}.V), numel(OMSC_list{i}.E));
end

%% ============================================================
% Construct ADG
%% ============================================================

fprintf('\nConstructing ADG...\n');

ADG = constructADG(OMSC_list);

fprintf('ADG: |V_d| = %d, |E_d| = %d\n', ...
    numel(ADG.V), numel(ADG.E));

%% ============================================================
% Attacked timed observation
%
% According to the corrected MATLAB model, the observable order is:
%   t01 -> t14 -> t24 -> t04
% i.e.,
%   a -> b -> c -> d.
%
% This observation is designed to be consistent with alpha_2:
% processing-time compression attack.
%
% One possible explanation under alpha_2 is:
%   t01 at time 2,
%   t14 at time 33,
%   t24 at time 56,
%   t04 at time 64.
%% ============================================================

w_a.labels = {'a','b','c','d'};
w_a.times  = [2, 12, 32, 52];

fprintf('\nAttacked timed observation:\n');
for i = 1:numel(w_a.labels)
    fprintf('(%s, %.4g)', w_a.labels{i}, w_a.times(i));
end
fprintf('\n');

%% ============================================================
% Attack detection
%% ============================================================

options.verbose = true;
options.tol = 1e-9;

[A, DET] = attackDetectionADG(ADG, w_a, options);

%% ============================================================
% Print detection result
%
% Convention:
%   A is assumed to store attack indices directly:
%       alpha_0, alpha_1, alpha_2, alpha_3
%   represented by:
%       0, 1, 2, 3.
%
%   DET.finalCandidates{c}.A usually stores MATLAB model indices:
%       G_list{1}, G_list{2}, G_list{3}, G_list{4}
%   corresponding to:
%       alpha_0, alpha_1, alpha_2, alpha_3.
%   Therefore, cand.A(k)-1 is printed.
%% ============================================================

fprintf('\n===== Detection Result =====\n');

fprintf('Raw A = ');
disp(A);

fprintf('Detected attack set: { ');
for i = 1:numel(A)
    fprintf('alpha_%d ', A(i));
end
fprintf('}\n');

fprintf('\nAttack hypotheses:\n');
for i = 1:numel(attackNames)
    fprintf('alpha_%d: %s\n', i-1, attackNames{i});
end

%% ============================================================
% Optional: print final candidates if available
%% ============================================================

if exist('DET','var') && isfield(DET,'finalCandidates')
    fprintf('\n===== Final Candidates =====\n');

    for c = 1:numel(DET.finalCandidates)
        cand = DET.finalCandidates{c};

        fprintf('Candidate %d: ', c);

        if isfield(cand,'v')
            fprintf('ADG vertex = %d, ', cand.v);
        end

        if isfield(cand,'A')
            fprintf('A_v = { ');
            for k = 1:numel(cand.A)
                fprintf('alpha_%d ', cand.A(k)-1);
            end
            fprintf('}');
        end

        fprintf('\n');
    end
end