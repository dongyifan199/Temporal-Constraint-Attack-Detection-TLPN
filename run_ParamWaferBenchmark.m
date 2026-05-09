clear; clc;

%% ============================================================
% Parameterized wafer benchmark
% r = 1 fixed
% n increases from 5 to 40
%% ============================================================

nList = [2, 5, 10, 20, 30, 40, 50, 60, 70, 80];

results = struct([]);

for k = 1:numel(nList)

    n = nList(k);

    fprintf('\n=========================================\n');
    fprintf('Wafer TLPN benchmark with n = %d, r = 1\n', n);
    fprintf('=========================================\n');

    [G_list, attackNames, meta] = makeParamWaferTLPNBenchmark(n);

    fprintf('|P| = %d, |T| = %d\n', meta.numPlaces, meta.numTransitions);

    numModels = numel(G_list);

    MSCG_list = cell(1,numModels);
    OMSC_list = cell(1,numModels);

    successFlag = true;
    errorMessage = '';

    try
        %% ============================================================
        % Construct MSCGs and OMSCGs
        %% ============================================================

        tic_MO = tic;

        for j = 1:numModels
            fprintf('Constructing for %s\n', attackNames{j});

            % Since r = 1 and the benchmark is sequential,
            % the state space should grow moderately with n.
            maxNodes = max(1000, 200*n);

            tic_single = tic;

            MSCG_list{j} = constructMSCGStrongMerged(G_list{j}, maxNodes);
            OMSC_list{j} = constructOMSCG(MSCG_list{j});

            singleTime = toc(tic_single);

            fprintf('    MSCG:  |V| = %d, |E| = %d\n', ...
                numel(MSCG_list{j}.V), numel(MSCG_list{j}.E));

            fprintf('    OMSCG: |V_o| = %d, |E_o| = %d\n', ...
                numel(OMSC_list{j}.V), numel(OMSC_list{j}.E));

            fprintf('    Time for this attack model: %.4f seconds\n', singleTime);

            results(k).singleModelTime(j) = singleTime;
            results(k).MSCGVertices(j) = numel(MSCG_list{j}.V);
            results(k).MSCGEdges(j) = numel(MSCG_list{j}.E);
            results(k).OMSCGVertices(j) = numel(OMSC_list{j}.V);
            results(k).OMSCGEdges(j) = numel(OMSC_list{j}.E);
        end

        time_MO = toc(tic_MO);

        %% ============================================================
        % Construct ADG
        %% ============================================================

        tic_ADG = tic;

        ADG = constructADG(OMSC_list);

        time_ADG = toc(tic_ADG);

        totalTime = time_MO + time_ADG;

        fprintf('\nADG: |V_d| = %d, |E_d| = %d\n', ...
            numel(ADG.V), numel(ADG.E));

        fprintf('Time for MSCG/OMSCG construction: %.4f seconds\n', time_MO);
        fprintf('Time for ADG construction:        %.4f seconds\n', time_ADG);
        fprintf('Total construction time:          %.4f seconds\n', totalTime);

        numADGVertices = numel(ADG.V);
        numADGEdges = numel(ADG.E);

    catch ME
        successFlag = false;
        errorMessage = ME.message;

        fprintf('\nFailed for n = %d\n', n);
        fprintf('Reason: %s\n', errorMessage);

        time_MO = NaN;
        time_ADG = NaN;
        totalTime = NaN;
        numADGVertices = NaN;
        numADGEdges = NaN;
    end

    %% ============================================================
    % Store results
    %% ============================================================

    results(k).n = n;
    results(k).numPlaces = meta.numPlaces;
    results(k).numTransitions = meta.numTransitions;

    results(k).numADGVertices = numADGVertices;
    results(k).numADGEdges = numADGEdges;

    results(k).time_MSCG_OMSCG = time_MO;
    results(k).time_ADG = time_ADG;
    results(k).time_total = totalTime;

    results(k).success = successFlag;
    results(k).errorMessage = errorMessage;
end

%% ============================================================
% Print summary table
%% ============================================================

fprintf('\n================ Summary ================\n');
fprintf(' n     |P|     |T|     |V_ADG|     |E_ADG|     T_MO(s)     T_ADG(s)     T_total(s)     status\n');
fprintf('------------------------------------------------------------------------------------------------\n');

for k = 1:numel(results)

    if results(k).success
        statusStr = 'OK';
    else
        statusStr = 'FAIL';
    end

    fprintf('%2d    %4d    %4d    %7.0f    %7.0f     %8.4f    %8.4f     %9.4f     %s\n', ...
        results(k).n, ...
        results(k).numPlaces, ...
        results(k).numTransitions, ...
        results(k).numADGVertices, ...
        results(k).numADGEdges, ...
        results(k).time_MSCG_OMSCG, ...
        results(k).time_ADG, ...
        results(k).time_total, ...
        statusStr);
end

%% Save results
save('wafer_nUpTo40_results.mat', 'results');