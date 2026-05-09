clear; clc;

%% ============================================================
% Build S^3PR TLPN benchmark
%
% M0 = k1*p3 + k2*p6 + r1*p7 + r2*p8
%% ============================================================

k1 = 2;
k2 = 2;
r1 = 1;
r2 = 2;

[G_list, attackNames, meta] = makeS3PRTLPNBenchmark(k1, k2, r1, r2);

fprintf('S^3PR TLPN benchmark\n');
fprintf('|P| = %d, |T| = %d\n', meta.numPlaces, meta.numTransitions);
fprintf('%s\n', meta.initialMarkingDescription);

fprintf('\nLabels:\n');
for t = 1:meta.numTransitions
    fprintf('  %s -> %s\n', meta.transitionNames{t}, meta.labels{t});
end

numModels = numel(G_list);

MSCG_list = cell(1,numModels);
OMSC_list = cell(1,numModels);

%% ============================================================
% Construct MSCGs and OMSCGs
%% ============================================================

for i = 1:numModels

    fprintf('\nConstructing MSCG and OMSCG for %s\n', attackNames{i});

    MSCG_list{i} = constructMSCGStrongMerged(G_list{i}, 1000);
    OMSC_list{i} = constructOMSCG(MSCG_list{i});

    fprintf('    MSCG:  |V| = %d, |E| = %d\n', ...
        numel(MSCG_list{i}.V), numel(MSCG_list{i}.E));

    fprintf('    OMSCG: |V_o| = %d, |E_o| = %d\n', ...
        numel(OMSC_list{i}.V), numel(OMSC_list{i}.E));
end

%% ============================================================
% Construct ADG
%% ============================================================

ADG = constructADG(OMSC_list);

fprintf('\nADG: |V_d| = %d, |E_d| = %d\n', ...
    numel(ADG.V), numel(ADG.E));

%% ============================================================
% Attacked timed observation
%
% l(t1)=a, l(t3)=b, l(t4)=c, l(t6)=d
%
% w_a = (a,2)(c,4)(b,9)(d,16)
%% ============================================================

w_a.labels = {'a','c','b'};
w_a.times  = [2, 3, 7];

options.verbose = true;
options.tol = 1e-9;

[A, DET] = attackDetectionADG(ADG, w_a, options);

%% ============================================================
% Print detection result
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

fprintf('\nAttack set is Abar = {alpha_0, alpha_1, alpha_2}.\n');