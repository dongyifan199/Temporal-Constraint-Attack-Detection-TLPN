clear; clc;

%% ============================================================
% Scalability evaluation for the parameterized wafer TLPN benchmark
%% ============================================================

nList = [2,5,10,20,30,40,50];

results = struct([]);

for k = 1:numel(nList)

    n = nList(k);

    fprintf('\n=========================================\n');
    fprintf('Parameterized wafer TLPN benchmark with n = %d\n', n);
    fprintf('=========================================\n');

    [G_list, attackNames, meta] = makeWaferTLPNBenchmark_FigModel(n);

    fprintf('|P| = %d, |T| = %d\n', meta.numPlaces, meta.numTransitions);
    fprintf('%s\n', meta.initialMarkingDescription);

    numModels = numel(G_list);

    MSCG_list = cell(1,numModels);
    OMSC_list = cell(1,numModels);

    successFlag = true;
    errorMessage = '';

    % Store graph sizes for each attack hypothesis
    MSCG_V = NaN(1,numModels);
    MSCG_E = NaN(1,numModels);
    OMSC_V = NaN(1,numModels);
    OMSC_E = NaN(1,numModels);
    singleModelTime = NaN(1,numModels);

    try
        %% ------------------------------------------------------------
        % Construct MSCGs and OMSCGs
        %% ------------------------------------------------------------

        tic_MO = tic;

        for j = 1:numModels

            fprintf('Constructing for %s\n', attackNames{j});

            % Increase this value if "Maximum number of nodes reached" occurs.
            maxNodes = max(3000, 800*n);

            tic_single = tic;

            MSCG_list{j} = constructMSCGStrongMerged(G_list{j}, maxNodes);
            OMSC_list{j} = constructOMSCG(MSCG_list{j});

            singleTime = toc(tic_single);

            MSCG_V(j) = numel(MSCG_list{j}.V);
            MSCG_E(j) = numel(MSCG_list{j}.E);
            OMSC_V(j) = numel(OMSC_list{j}.V);
            OMSC_E(j) = numel(OMSC_list{j}.E);
            singleModelTime(j) = singleTime;

            fprintf('    MSCG:  |V| = %d, |E| = %d\n', MSCG_V(j), MSCG_E(j));
            fprintf('    OMSCG: |V_o| = %d, |E_o| = %d\n', OMSC_V(j), OMSC_E(j));
            fprintf('    Time: %.4f seconds\n', singleTime);
        end

        time_MO = toc(tic_MO);

        %% ------------------------------------------------------------
        % Construct ADG
        %% ------------------------------------------------------------

        tic_ADG = tic;

        ADG = constructADG(OMSC_list);

        time_ADG = toc(tic_ADG);
        totalTime = time_MO + time_ADG;

        numADGVertices = numel(ADG.V);
        numADGEdges = numel(ADG.E);

        fprintf('ADG: |V_d| = %d, |E_d| = %d\n', ...
            numADGVertices, numADGEdges);

        fprintf('T_MO = %.4f, T_ADG = %.4f, T_total = %.4f\n', ...
            time_MO, time_ADG, totalTime);

    catch ME
        successFlag = false;
        errorMessage = ME.message;

        fprintf('FAILED: %s\n', errorMessage);

        time_MO = NaN;
        time_ADG = NaN;
        totalTime = NaN;
        numADGVertices = NaN;
        numADGEdges = NaN;
    end

    %% ------------------------------------------------------------
    % Store results
    %% ------------------------------------------------------------

    results(k).n = n;
    results(k).numPlaces = meta.numPlaces;
    results(k).numTransitions = meta.numTransitions;

    results(k).MSCG_V = MSCG_V;
    results(k).MSCG_E = MSCG_E;
    results(k).OMSC_V = OMSC_V;
    results(k).OMSC_E = OMSC_E;
    results(k).singleModelTime = singleModelTime;

    results(k).totalMSCGVertices = sum(MSCG_V, 'omitnan');
    results(k).totalMSCGEdges = sum(MSCG_E, 'omitnan');
    results(k).totalOMSCGVertices = sum(OMSC_V, 'omitnan');
    results(k).totalOMSCGEdges = sum(OMSC_E, 'omitnan');

    results(k).numADGVertices = numADGVertices;
    results(k).numADGEdges = numADGEdges;

    results(k).time_MSCG_OMSCG = time_MO;
    results(k).time_ADG = time_ADG;
    results(k).time_total = totalTime;

    results(k).success = successFlag;
    results(k).errorMessage = errorMessage;
end

%% ============================================================
% Summary
%% ============================================================

fprintf('\n================ Summary ================\n');
fprintf(' n     |P|     |T|    |V_M|    |E_M|    |V_O|    |E_O|    |V_ADG|    |E_ADG|    T_MO(s)    T_ADG(s)    T_total(s)    status\n');
fprintf('--------------------------------------------------------------------------------------------------------------------------------\n');

for k = 1:numel(results)

    if results(k).success
        statusStr = 'OK';
    else
        statusStr = 'FAIL';
    end

    fprintf('%3d   %5d   %5d   %6.0f   %6.0f   %6.0f   %6.0f   %7.0f   %7.0f    %8.4f   %8.4f    %9.4f    %s\n', ...
        results(k).n, ...
        results(k).numPlaces, ...
        results(k).numTransitions, ...
        results(k).totalMSCGVertices, ...
        results(k).totalMSCGEdges, ...
        results(k).totalOMSCGVertices, ...
        results(k).totalOMSCGEdges, ...
        results(k).numADGVertices, ...
        results(k).numADGEdges, ...
        results(k).time_MSCG_OMSCG, ...
        results(k).time_ADG, ...
        results(k).time_total, ...
        statusStr);
end
