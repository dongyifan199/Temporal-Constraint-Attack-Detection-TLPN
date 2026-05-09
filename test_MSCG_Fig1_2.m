clear; clc;

% Places: p1,...,p5
% Transitions: t1,...,t5
%
% Fig. 1:
% t1: p1 -> p2 + p3
% t2: p2 -> p4
% t3: p3 -> p5
% t4: p4 -> p2
% t5: p4 + p5 -> p1

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

G.I = [3 6.99;
       5 6.99;
       4 5.99;
       5 8.99;
       1 4.99];

MSCG = constructMSCGStrongMerged(G, 100);

fprintf('\nNumber of vertices: %d\n', numel(MSCG.V));
fprintf('Number of edges: %d\n\n', numel(MSCG.E));

fprintf('===== Vertices =====\n');
for i = 1:numel(MSCG.V)
    v = MSCG.V(i);
    fprintf('v%d: M = %s\n', i-1, mat2str(v.M'));

    for k = 1:numel(v.Theta)
        th = v.Theta(k);
        lb = boundToStringLocal(th.lb, MSCG.varNames, "max");
        ub = boundToStringLocal(th.ub, MSCG.varNames, "min");
        fprintf('    %s <= theta_%d < %s\n', lb, th.t, ub);
    end
end

fprintf('\n===== Edges =====\n');
for i = 1:numel(MSCG.E)
    e = MSCG.E(i);
    fprintf('e%d = (v%d, t%d, %s, %s in [%s, %s), v%d)\n', ...
        i, e.source-1, e.transition, e.label, e.DeltaName, ...
        e.DeltaLB, e.DeltaUB, e.target-1);
end

%% Local display helpers