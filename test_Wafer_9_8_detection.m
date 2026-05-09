clear; clc;

%% ============================================================
% Build small wafer benchmark: |P|=9, |T|=8
%% ============================================================

[G_list, attackNames, meta] = makeWaferTLPNBenchmark_9_8();

numModels = numel(G_list);

MSCG_list = cell(1,numModels);
OMSC_list = cell(1,numModels);

for i = 1:numModels
    fprintf('Constructing MSCG and OMSCG for %s\n', attackNames{i});

    MSCG_list{i} = constructMSCGStrongMerged(G_list{i}, 300);
    OMSC_list{i} = constructOMSCG(MSCG_list{i});

    fprintf('    MSCG:  |V| = %d, |E| = %d\n', ...
        numel(MSCG_list{i}.V), numel(MSCG_list{i}.E));

    fprintf('    OMSCG: |V_o| = %d, |E_o| = %d\n', ...
        numel(OMSC_list{i}.V), numel(OMSC_list{i}.E));
end

%% ============================================================
% Build ADG
%% ============================================================

ADG = constructADG(OMSC_list);

fprintf('\nADG: |V_d| = %d, |E_d| = %d\n', ...
    numel(ADG.V), numel(ADG.E));

%% ============================================================
% Attacked timed observation
%
% This observation is designed to be consistent with alpha_2:
% processing-recipe compression attack.
%
% w_a = (a,2)(b,22)(c,47)(d,48.5)
%% ============================================================

w_a.labels = {'a','b','c','d'};
w_a.times  = [2, 22, 47, 48.5];

options.verbose = true;
options.tol = 1e-9;

[A, DET] = attackDetectionADG(ADG, w_a, options);

%% ============================================================
% Print result
%% ============================================================

fprintf('\n===== Detection Result =====\n');
fprintf('w_a = ');
for i = 1:numel(w_a.labels)
    fprintf('(%s, %.4g)', w_a.labels{i}, w_a.times(i));
end
fprintf('\n');

fprintf('A = { ');
for i = 1:numel(A)
    fprintf('alpha_%d ', A(i));
end
fprintf('}\n');

fprintf('\nExpected result: A = { alpha_2 }\n');

%% ============================================================
% Optional: print final candidate details
%% ============================================================

fprintf('\n===== Final Candidates =====\n');

for c = 1:numel(DET.finalCandidates)
    cand = DET.finalCandidates{c};

    fprintf('Candidate %d: ADG vertex vd%d, A_v = { ', ...
        c, cand.v - 1);

    for k = 1:numel(cand.A)
        fprintf('alpha_%d ', cand.A(k)-1);
    end

    fprintf('}\n');
end