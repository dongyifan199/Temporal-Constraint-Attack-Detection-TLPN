clear; clc;

% First construct MSCG using the previous verified code.
% Places: p1,...,p5
% Transitions: t1,...,t5

Pre = [1 0 0 0 0;
       0 1 0 0 0;
       0 0 1 0 0;
       0 0 0 1 1;
       0 0 0 0 1];

Post = [0 0 0 0 1;
        1 0 0 1 0;
        1 0 0 0 0;
        0 1 0 0 0;
        0 0 1 0 0];

G.Pre = Pre;
G.Post = Post;
G.M0 = [1;0;0;0;0];

G.labels = {'eps','a','eps','b','b'};

G.I = [2 5;
       5 7;
       4 6;
       3 6;
       1 5];

MSCG = constructMSCGStrongMerged(G, 100);

% Construct OMSC G from MSCG.
OMSC = constructOMSCG(MSCG);

fprintf('\n===== OMSC Vertices =====\n');
for i = 1:numel(OMSC.V)
    v = OMSC.V(i);
    fprintf('vo%d corresponds to MSCG v%d, M = %s\n', ...
        i-1, v.origID-1, mat2str(v.M'));
end

fprintf('\n===== OMSC Edges =====\n');
for i = 1:numel(OMSC.E)
    e = OMSC.E(i);

    fprintf('eo%d = (vo%d, %s, %s, CO, vo%d)\n', ...
        i, e.source-1, e.label, e.Delta, e.target-1);

    fprintf('      MSCG path edges: ');
    fprintf('e%d ', e.pathEdges);
    fprintf('\n');

    fprintf('      CO = { ');
    for k = 1:numel(e.CO)
        fprintf('%s', e.CO{k});
        if k < numel(e.CO)
            fprintf(', ');
        end
    end
    fprintf(' }\n');
end