clear; clc;

n = 1;

[G_list, attackNames, meta] = makeWaferTLPNBenchmark_FigModel(n);

numModels = numel(G_list);

MSCG_list = cell(1,numModels);
OMSC_list = cell(1,numModels);

for j = 1:numModels
    fprintf('\nConstructing for %s\n', attackNames{j});

    MSCG_list{j} = constructMSCGStrongMerged(G_list{j}, 1000);
    OMSC_list{j} = constructOMSCG(MSCG_list{j});

    fprintf('    MSCG:  |V| = %d, |E| = %d\n', ...
        numel(MSCG_list{j}.V), numel(MSCG_list{j}.E));

    fprintf('    OMSCG: |V_o| = %d, |E_o| = %d\n', ...
        numel(OMSC_list{j}.V), numel(OMSC_list{j}.E));
end

ADG = constructADG(OMSC_list);

fprintf('\nADG: |V_d| = %d, |E_d| = %d\n', ...
    numel(ADG.V), numel(ADG.E));