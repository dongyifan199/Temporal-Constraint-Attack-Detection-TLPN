clear; clc;

%% ============================================================
% Token scalability test for S^3PR benchmark
%
% M0 = k1*p3 + k2*p6 + r1*p7 + r2*p8
%
% For each initial marking, this script constructs:
%   - MSCGs under all attack hypotheses;
%   - OMSCGs under all attack hypotheses;
%   - ADG generated from the OMSCGs.
%
% Summary columns:
%   |V|      : total number of MSCG vertices over all attack hypotheses
%   |V_o|    : total number of OMSCG vertices over all attack hypotheses
%   |V_ADG|  : number of ADG vertices
%   T_MO     : total time for constructing all MSCGs and OMSCGs
%   T_ADG    : time for constructing the ADG
%   T_total  : T_MO + T_ADG
%% ============================================================

caseList = [
    % k1 k2 r1 r2
    % 1 1 1 2;
    % 1 1 2 1;
    2 2 1 2;
    2 2 2 1;
    3 3 1 2;
    3 3 2 1;

    % 1 1 1 3;
    % 1 1 3 1;
    2 2 1 3;
    2 2 3 1;
    3 3 1 3;
    3 3 3 1;

    % 1 1 1 4;
    % 1 1 4 1;
    2 2 1 4;
    2 2 4 1;
    3 3 1 4;
    3 3 4 1;

    %4 4 1 3;
    2 2 1 5;
    2 2 5 1;
    3 3 1 5;
    3 3 5 1;
];

results = struct([]);

for cc = 1:size(caseList,1)

    k1 = caseList(cc,1);
    k2 = caseList(cc,2);
    r1 = caseList(cc,3);
    r2 = caseList(cc,4);

    fprintf('\n=========================================\n');
    fprintf('S^3PR TLPN benchmark: k1=%d, k2=%d, r1=%d, r2=%d\n', ...
        k1, k2, r1, r2);
    fprintf('=========================================\n');

    [G_list, attackNames, meta] = makeS3PRTLPNBenchmark(k1, k2, r1, r2);

    fprintf('|P| = %d, |T| = %d\n', meta.numPlaces, meta.numTransitions);
    fprintf('%s\n', meta.initialMarkingDescription);

    numModels = numel(G_list);

    MSCG_list = cell(1,numModels);
    OMSC_list = cell(1,numModels);

    successFlag = true;
    errorMessage = '';

    MSCGVertices = NaN(1,numModels);
    MSCGEdges = NaN(1,numModels);
    OMSCGVertices = NaN(1,numModels);
    OMSCGEdges = NaN(1,numModels);
    singleModelTime = NaN(1,numModels);

    try
        %% ------------------------------------------------------------
        % MSCG and OMSCG construction
        %% ------------------------------------------------------------

        tic_MO = tic;

        for j = 1:numModels

            fprintf('Constructing for %s\n', attackNames{j});

            maxNodes = max(1000, 1000*(k1+k2));

            tic_single = tic;

            MSCG_list{j} = constructMSCGStrongMerged(G_list{j}, maxNodes);
            OMSC_list{j} = constructOMSCG(MSCG_list{j});

            singleTime = toc(tic_single);

            MSCGVertices(j) = numel(MSCG_list{j}.V);
            MSCGEdges(j) = numel(MSCG_list{j}.E);
            OMSCGVertices(j) = numel(OMSC_list{j}.V);
            OMSCGEdges(j) = numel(OMSC_list{j}.E);
            singleModelTime(j) = singleTime;

            fprintf('    MSCG:  |V| = %d, |E| = %d\n', ...
                MSCGVertices(j), MSCGEdges(j));

            fprintf('    OMSCG: |V_o| = %d, |E_o| = %d\n', ...
                OMSCGVertices(j), OMSCGEdges(j));

            fprintf('    Time for this attack model: %.4f seconds\n', ...
                singleTime);
        end

        time_MO = toc(tic_MO);

        %% ------------------------------------------------------------
        % ADG construction
        %% ------------------------------------------------------------

        tic_ADG = tic;

        ADG = constructADG(OMSC_list);

        time_ADG = toc(tic_ADG);

        totalTime = time_MO + time_ADG;

        numADGVertices = numel(ADG.V);
        numADGEdges = numel(ADG.E);

        totalMSCGVertices = sum(MSCGVertices, 'omitnan');
        totalMSCGEdges = sum(MSCGEdges, 'omitnan');
        totalOMSCGVertices = sum(OMSCGVertices, 'omitnan');
        totalOMSCGEdges = sum(OMSCGEdges, 'omitnan');

        fprintf('\nADG: |V_d| = %d, |E_d| = %d\n', ...
            numADGVertices, numADGEdges);

        fprintf('Total MSCG vertices:  %d\n', totalMSCGVertices);
        fprintf('Total OMSCG vertices: %d\n', totalOMSCGVertices);
        fprintf('Time for MSCG/OMSCG construction: %.4f seconds\n', time_MO);
        fprintf('Time for ADG construction:        %.4f seconds\n', time_ADG);
        fprintf('Total construction time:          %.4f seconds\n', totalTime);

    catch ME
        successFlag = false;
        errorMessage = ME.message;

        fprintf('\nFAILED for k1=%d, k2=%d, r1=%d, r2=%d\n', ...
            k1, k2, r1, r2);
        fprintf('Reason: %s\n', errorMessage);

        time_MO = NaN;
        time_ADG = NaN;
        totalTime = NaN;

        numADGVertices = NaN;
        numADGEdges = NaN;

        totalMSCGVertices = NaN;
        totalMSCGEdges = NaN;
        totalOMSCGVertices = NaN;
        totalOMSCGEdges = NaN;
    end

    %% ------------------------------------------------------------
    % Store results
    %% ------------------------------------------------------------

    results(cc).k1 = k1;
    results(cc).k2 = k2;
    results(cc).r1 = r1;
    results(cc).r2 = r2;

    results(cc).numPlaces = meta.numPlaces;
    results(cc).numTransitions = meta.numTransitions;

    results(cc).MSCGVertices = MSCGVertices;
    results(cc).MSCGEdges = MSCGEdges;
    results(cc).OMSCGVertices = OMSCGVertices;
    results(cc).OMSCGEdges = OMSCGEdges;
    results(cc).singleModelTime = singleModelTime;

    results(cc).totalMSCGVertices = totalMSCGVertices;
    results(cc).totalMSCGEdges = totalMSCGEdges;
    results(cc).totalOMSCGVertices = totalOMSCGVertices;
    results(cc).totalOMSCGEdges = totalOMSCGEdges;

    results(cc).numADGVertices = numADGVertices;
    results(cc).numADGEdges = numADGEdges;

    results(cc).time_MSCG_OMSCG = time_MO;
    results(cc).time_ADG = time_ADG;
    results(cc).time_total = totalTime;

    results(cc).success = successFlag;
    results(cc).errorMessage = errorMessage;
end

%% ============================================================
% Summary table
%% ============================================================

fprintf('\n================ Summary ================\n');
fprintf(' k1   k2   r1   r2   |P|   |T|     |V|     |V_o|   |V_ADG|    T_MO(s)    T_ADG(s)    T_total(s)    status\n');
fprintf('-----------------------------------------------------------------------------------------------------------------\n');

for cc = 1:numel(results)

    if results(cc).success
        statusStr = 'OK';
    else
        statusStr = 'FAIL';
    end

    fprintf('%2d   %2d   %2d   %2d   %4d  %4d   %7.0f   %7.0f   %7.0f    %8.4f    %8.4f     %9.4f     %s\n', ...
        results(cc).k1, ...
        results(cc).k2, ...
        results(cc).r1, ...
        results(cc).r2, ...
        results(cc).numPlaces, ...
        results(cc).numTransitions, ...
        results(cc).totalMSCGVertices, ...
        results(cc).totalOMSCGVertices, ...
        results(cc).numADGVertices, ...
        results(cc).time_MSCG_OMSCG, ...
        results(cc).time_ADG, ...
        results(cc).time_total, ...
        statusStr);
end

save('s3pr_token_results.mat', 'results');