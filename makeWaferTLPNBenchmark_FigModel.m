% function [G_list, attackNames, meta] = makeWaferTLPNBenchmark_FigModel(n)
% makeWaferTLPNBenchmark_FigModel
% Parameterized wafer processing TLPN benchmark based on the figure model.
% 
% The model contains:
%   - one loadlock step, indexed by 0;
%   - n processing modules, indexed by 1,...,n;
%   - one robot resource place p_r.
% 
% For each step i = 0,1,...,n:
%   places:      p_{i1}, p_{i2}, p_{i3}, p_{i4}
%   transitions: t_{i1}, t_{i2}, t_{i3}, t_{i4}
% 
% Therefore:
%   |P| = 4(n+1) + 1 = 4n + 5
%   |T| = 4(n+1)     = 4n + 4
% 
% For the n=2 case used in the paper:
%   |P| = 13, |T| = 12.
% 
% Initial marking:
%   M0 = p_{04} + p_r.
% 
% For n=2:
%   l(t_{01}) = a
%   l(t_{14}) = b
%   l(t_{24}) = c
%   l(t_{04}) = d
%   all other transitions are unobservable.
% 
% Output:
%   G_list{1}: alpha_0, no attack
%   G_list{2}: alpha_1, robot-speed attack
%   G_list{3}: alpha_2, processing-time compression attack
%   G_list{4}: alpha_3, waiting-time manipulation attack
% 
% if nargin < 1
%     n = 2;
% end
% 
% if n < 1
%     error('n must be a positive integer.');
% end
% 
% numSteps = n + 1;          % step 0 + modules 1,...,n
% numP = 4*numSteps + 1;     % four places per step + p_r
% numT = 4*numSteps;         % four transitions per step
% 
% % ============================================================
% Indexing
% 
% MATLAB index convention:
%   p(i+1,j) represents p_{ij}, i = 0,1,...,n, j = 1,2,3,4.
%   t(i+1,j) represents t_{ij}, i = 0,1,...,n, j = 1,2,3,4.
% % ============================================================
% 
% idx.p = zeros(n+1,4);
% idx.t = zeros(n+1,4);
% 
% cntP = 0;
% for i = 0:n
%     for j = 1:4
%         cntP = cntP + 1;
%         idx.p(i+1,j) = cntP;
%     end
% end
% 
% idx.pr = numP;
% 
% cntT = 0;
% for i = 0:n
%     for j = 1:4
%         cntT = cntT + 1;
%         idx.t(i+1,j) = cntT;
%     end
% end
% 
% Pre  = zeros(numP,numT);
% Post = zeros(numP,numT);
% 
% % ============================================================
% Topology
% 
% Loadlock part:
%   p_r            --t_{01}--> p_{01}
%   p_{01}         --t_{02}--> p_{02}
%   p_{02}+p_{04}  --t_{03}--> p_{13}
%   p_{03}         --t_{04}--> p_{04}+p_r
% 
% Module i, i = 1,...,n:
%   p_r              --t_{i1}--> p_{i1}
%   p_{i1}           --t_{i2}--> p_{i2}
%   p_{i2}+p_{i4}    --t_{i3}--> p_{(i+1)3}, if i<n
%   p_{n2}+p_{n4}    --t_{n3}--> p_{03}, if i=n
%   p_{i3}           --t_{i4}--> p_{i4}+p_r
% 
% For n=2, a natural observable order is:
%   t_{01} -> t_{14} -> t_{24} -> t_{04},
% i.e.,
%   a -> b -> c -> d.
% % ============================================================
% 
% ---------- loadlock places ----------
% p01 = idx.p(1,1);
% p02 = idx.p(1,2);
% p03 = idx.p(1,3);
% p04 = idx.p(1,4);
% 
% ---------- loadlock transitions ----------
% t01 = idx.t(1,1);
% t02 = idx.t(1,2);
% t03 = idx.t(1,3);
% t04 = idx.t(1,4);
% 
% t_{01}: initiation of wafer-loading procedure from the loadlock
% Pre(idx.pr,t01) = 1;
% Post(p01,t01) = 1;
% 
% t_{02}: internal loadlock operation
% Pre(p01,t02) = 1;
% Post(p02,t02) = 1;
% 
% t_{03}: loadlock-ready operation; wafer becomes ready for module 1
% Pre(p02,t03) = 1;
% Pre(p04,t03) = 1;
% Post(idx.p(2,3),t03) = 1;   % p_{13}
% 
% t_{04}: return/unloading operation to the loadlock
% Pre(p03,t04) = 1;
% Post(p04,t04) = 1;
% Post(idx.pr,t04) = 1;
% 
% ---------- processing modules ----------
% for i = 1:n
% 
%     ii = i + 1;
% 
%     p_i1 = idx.p(ii,1);
%     p_i2 = idx.p(ii,2);
%     p_i3 = idx.p(ii,3);
%     p_i4 = idx.p(ii,4);
% 
%     t_i1 = idx.t(ii,1);
%     t_i2 = idx.t(ii,2);
%     t_i3 = idx.t(ii,3);
%     t_i4 = idx.t(ii,4);
% 
%     t_{i1}: scheduled robot/waiting operation associated with module i
%     Pre(idx.pr,t_i1) = 1;
%     Post(p_i1,t_i1) = 1;
% 
%     t_{i2}: internal processing or waiting operation in module i
%     Pre(p_i1,t_i2) = 1;
%     Post(p_i2,t_i2) = 1;
% 
%     t_{i3}: after-processing transition using p_{i2} and p_{i4}
%     Pre(p_i2,t_i3) = 1;
%     Pre(p_i4,t_i3) = 1;
% 
%     if i < n
%         output to the ready place of the next module
%         Post(idx.p(i+2,3),t_i3) = 1;   % p_{(i+1)3}
%     else
%         after the last module, output to p_{03}
%         Post(p03,t_i3) = 1;
%     end
% 
%     t_{i4}: robot-transfer operation after local processing
%     Pre(p_i3,t_i4) = 1;
%     Post(p_i4,t_i4) = 1;
%     Post(idx.pr,t_i4) = 1;
% end
% 
% % ============================================================
% Initial marking
% 
% M0 = p_{04} + p_r
% % ============================================================
% 
% M0 = zeros(numP,1);
% M0(p04) = 1;
% M0(idx.pr) = 1;
% 
% % ============================================================
% Labels
% 
% For n=2:
%   t_{01}: a
%   t_{14}: b
%   t_{24}: c
%   t_{04}: d
% 
% All other transitions are unobservable.
% % ============================================================
% 
% labels = cell(1,numT);
% 
% Initialize all transitions as unobservable
% for i = 0:n
%     for j = 1:4
%         labels{idx.t(i+1,j)} = 'eps';
%     end
% end
% 
% if n == 2
%     labels{idx.t(1,1)} = 'a';   % t_{01}
%     labels{idx.t(2,4)} = 'b';   % t_{14}
%     labels{idx.t(3,4)} = 'c';   % t_{24}
%     labels{idx.t(1,4)} = 'd';   % t_{04}
% else
%     labels{idx.t(1,1)} = 'a';   % t_{01}
% 
%     for i = 1:n
%         labels{idx.t(i+1,4)} = sprintf('b%d',i);  % t_{i4}
%     end
% 
%     labels{idx.t(1,4)} = 'd';   % t_{04}
% end
% 
% % ============================================================
% Nominal time intervals I0
% 
% For n=2:
%   I(t01) = [1,3]
%   I(t02) = [2,5]
%   I(t03) = [1,3]
%   I(t04) = [2,5]
%   I(t11) = [1.2,3.3]
%   I(t12) = [20,30]
%   I(t13) = [0,6]
%   I(t14) = [3,6]
%   I(t21) = [1.4,3.6]
%   I(t22) = [22,32]
%   I(t23) = [0,7]
%   I(t24) = [2,5]
% % ============================================================
% 
% I0 = zeros(numT,2);
% 
% for i = 0:n
%     ii = i + 1;
% 
%     t_{i1}: scheduled/robot-related operation
%     I0(idx.t(ii,1),:) = [1, 3] + i*[0.2, 0.3];
% 
%     t_{i2}: processing/internal operation
%     if i == 0
%         I0(idx.t(ii,2),:) = [2, 5];
%     else
%         I0(idx.t(ii,2),:) = [18+2*i, 28+2*i];
%     end
% 
%     t_{i3}: waiting/ready operation
%     if i == 0
%         I0(idx.t(ii,3),:) = [1, 3];
%     else
%         I0(idx.t(ii,3),:) = [0, 5+i];
%     end
% 
%     t_{i4}: robot-transfer / return operation
%     I0(idx.t(ii,4),:) = [2, 5] + mod(i,2)*[1,1];
% end
% 
% % ============================================================
% Attack alpha_1: robot-speed attack
% 
% The robot-related observable operations are delayed.
% For n=2, affected transitions:
%   t_{01}, t_{14}, t_{24}, t_{04}.
% % ============================================================
% 
% I1 = I0;
% 
% if n == 2
%     I1(idx.t(1,1),:) = I0(idx.t(1,1),:) + [1,2];   % t_{01}
%     I1(idx.t(2,4),:) = I0(idx.t(2,4),:) + [2,3];   % t_{14}
%     I1(idx.t(3,4),:) = I0(idx.t(3,4),:) + [2,3];   % t_{24}
%     I1(idx.t(1,4),:) = I0(idx.t(1,4),:) + [1,2];   % t_{04}
% else
%     I1(idx.t(1,1),:) = I0(idx.t(1,1),:) + [1,2];   % t_{01}
% 
%     for i = 1:n
%         I1(idx.t(i+1,4),:) = I0(idx.t(i+1,4),:) + [2,3]; % t_{i4}
%     end
% 
%     I1(idx.t(1,4),:) = I0(idx.t(1,4),:) + [1,2];   % t_{04}
% end
% 
% % ============================================================
% Attack alpha_2: processing-time compression attack
% 
% The internal processing operations in processing modules are shortened.
% Vulnerable transitions:
%   t_{i2}, i=1,...,n.
% 
% For n=2:
%   t_{12}, t_{22}.
% % ============================================================
% 
% I2 = I0;
% 
% for i = 1:n
%     ii = i + 1;
% 
%     oldL = I0(idx.t(ii,2),1);
%     oldU = I0(idx.t(ii,2),2);
% 
%     newL = max(1, floor(0.65*oldL));
%     newU = max(newL+1, floor(0.80*oldU));
% 
%     I2(idx.t(ii,2),:) = [newL,newU];
% end
% 
% % ============================================================
% Attack alpha_3: waiting-time manipulation attack
% 
% The waiting/ready operations are delayed.
% Vulnerable transitions:
%   t_{i3}, i=0,1,...,n.
% 
% For n=2:
%   t_{03}, t_{13}, t_{23}.
% % ============================================================
% 
% I3 = I0;
% 
% for i = 0:n
%     ii = i + 1;
% 
%     I3(idx.t(ii,3),:) = I0(idx.t(ii,3),:) + [2,4];
% end
% 
% % ============================================================
% Build TLPNs
% % ============================================================
% 
% G0.Pre = Pre;
% G0.Post = Post;
% G0.M0 = M0;
% G0.labels = labels;
% G0.I = I0;
% 
% G1 = G0;
% G1.I = I1;
% 
% G2 = G0;
% G2.I = I2;
% 
% G3 = G0;
% G3.I = I3;
% 
% G_list = {G0,G1,G2,G3};
% 
% attackNames = { ...
%     'alpha_0: no attack', ...
%     'alpha_1: robot-speed attack', ...
%     'alpha_2: processing-time compression attack', ...
%     'alpha_3: waiting-time manipulation attack'};
% 
% % ============================================================
% Meta information
% % ============================================================
% 
% meta.n = n;
% meta.numSteps = numSteps;
% meta.numPlaces = numP;
% meta.numTransitions = numT;
% meta.idx = idx;
% 
% meta.placeNames = cell(1,numP);
% for i = 0:n
%     for j = 1:4
%         meta.placeNames{idx.p(i+1,j)} = sprintf('p_%d%d',i,j);
%     end
% end
% meta.placeNames{idx.pr} = 'p_r';
% 
% meta.transitionNames = cell(1,numT);
% for i = 0:n
%     for j = 1:4
%         meta.transitionNames{idx.t(i+1,j)} = sprintf('t_%d%d',i,j);
%     end
% end
% 
% meta.labels = labels;
% meta.initialMarkingDescription = 'M0 = p_04 + p_r';
% 
% if n == 2
%     meta.observableTransitionIndices = [ ...
%         idx.t(1,1), ...  % t_{01}
%         idx.t(2,4), ...  % t_{14}
%         idx.t(3,4), ...  % t_{24}
%         idx.t(1,4)  ...  % t_{04}
%     ];
% else
%     meta.observableTransitionIndices = idx.t(1,1);  % t_{01}
% 
%     for i = 1:n
%         meta.observableTransitionIndices = [ ...
%             meta.observableTransitionIndices, idx.t(i+1,4)];
%     end
% 
%     meta.observableTransitionIndices = [ ...
%         meta.observableTransitionIndices, idx.t(1,4)];
% end
% 
% meta.unobservableTransitionIndices = setdiff(1:numT, meta.observableTransitionIndices);
% 
% meta.observableTransitions = meta.transitionNames(meta.observableTransitionIndices);
% meta.unobservableTransitions = meta.transitionNames(meta.unobservableTransitionIndices);
% 
% meta.vulnerableTransitions.alpha1 = meta.transitionNames(meta.observableTransitionIndices);
% 
% meta.vulnerableTransitions.alpha2 = cell(1,n);
% for i = 1:n
%     meta.vulnerableTransitions.alpha2{i} = meta.transitionNames{idx.t(i+1,2)};
% end
% 
% meta.vulnerableTransitions.alpha3 = cell(1,n+1);
% for i = 0:n
%     meta.vulnerableTransitions.alpha3{i+1} = meta.transitionNames{idx.t(i+1,3)};
% end
% 
% meta.attackNames = attackNames;
% 
% end



function [G_list, attackNames, meta] = makeWaferTLPNBenchmark_FigModel(n)
% makeWaferTLPNBenchmark_FigModel
% Parameterized wafer processing TLPN benchmark based on the figure model.
%
% The model contains:
%   - one loadlock step, indexed by 0;
%   - n processing modules, indexed by 1,...,n;
%   - one robot resource place p_r.
%
% For each step i = 0,1,...,n:
%   places:      p_{i1}, p_{i2}, p_{i3}, p_{i4}
%   transitions: t_{i1}, t_{i2}, t_{i3}, t_{i4}
%
% Therefore:
%   |P| = 4(n+1) + 1 = 4n + 5
%   |T| = 4(n+1)     = 4n + 4
%
% For the n=2 case used in the paper:
%   |P| = 13, |T| = 12.
%
% Initial marking:
%   M0 = p_{04} + p_r.
%
% For n=2:
%   l(t_{01}) = a
%   l(t_{14}) = b
%   l(t_{24}) = c
%   l(t_{04}) = d
%   all other transitions are unobservable.
%
% Output:
%   G_list{1}: alpha_0, no attack
%   G_list{2}: alpha_1, robot-speed attack
%   G_list{3}: alpha_2, processing-time compression attack
%   G_list{4}: alpha_3, waiting-time manipulation attack

if nargin < 1
    n = 2;
end

if n < 1
    error('n must be a positive integer.');
end

numSteps = n + 1;          % step 0 + modules 1,...,n
numP = 4*numSteps + 1;     % four places per step + p_r
numT = 4*numSteps;         % four transitions per step

%% ============================================================
% Indexing
%
% MATLAB index convention:
%   p(i+1,j) represents p_{ij}, i = 0,1,...,n, j = 1,2,3,4.
%   t(i+1,j) represents t_{ij}, i = 0,1,...,n, j = 1,2,3,4.
%% ============================================================

idx.p = zeros(n+1,4);
idx.t = zeros(n+1,4);

cntP = 0;
for i = 0:n
    for j = 1:4
        cntP = cntP + 1;
        idx.p(i+1,j) = cntP;
    end
end

idx.pr = numP;

cntT = 0;
for i = 0:n
    for j = 1:4
        cntT = cntT + 1;
        idx.t(i+1,j) = cntT;
    end
end

Pre  = zeros(numP,numT);
Post = zeros(numP,numT);

%% ============================================================
% Topology
%
% Loadlock part:
%   p_r            --t_{01}--> p_{01}
%   p_{01}         --t_{02}--> p_{02}
%   p_{02}+p_{04}  --t_{03}--> p_{13}
%   p_{03}         --t_{04}--> p_{04}+p_r
%
% Module i, i = 1,...,n:
%   p_r              --t_{i1}--> p_{i1}
%   p_{i1}           --t_{i2}--> p_{i2}
%   p_{i2}+p_{i4}    --t_{i3}--> p_{(i+1)3}, if i<n
%   p_{n2}+p_{n4}    --t_{n3}--> p_{03}, if i=n
%   p_{i3}           --t_{i4}--> p_{i4}+p_r
%
% For n=2, a natural observable order is:
%   t_{01} -> t_{14} -> t_{24} -> t_{04},
% i.e.,
%   a -> b -> c -> d.
%% ============================================================

% ---------- loadlock places ----------
p01 = idx.p(1,1);
p02 = idx.p(1,2);
p03 = idx.p(1,3);
p04 = idx.p(1,4);

% ---------- loadlock transitions ----------
t01 = idx.t(1,1);
t02 = idx.t(1,2);
t03 = idx.t(1,3);
t04 = idx.t(1,4);

% t_{01}: initiation of wafer-loading procedure from the loadlock
Pre(idx.pr,t01) = 1;
Post(p01,t01) = 1;

% t_{02}: internal loadlock operation
Pre(p01,t02) = 1;
Post(p02,t02) = 1;

% t_{03}: loadlock-ready operation; wafer becomes ready for module 1
Pre(p02,t03) = 1;
Pre(p04,t03) = 1;
Post(idx.p(2,3),t03) = 1;   % p_{13}

% t_{04}: return/unloading operation to the loadlock
Pre(p03,t04) = 1;
Post(p04,t04) = 1;
Post(idx.pr,t04) = 1;

% ---------- processing modules ----------
for i = 1:n

    ii = i + 1;

    p_i1 = idx.p(ii,1);
    p_i2 = idx.p(ii,2);
    p_i3 = idx.p(ii,3);
    p_i4 = idx.p(ii,4);

    t_i1 = idx.t(ii,1);
    t_i2 = idx.t(ii,2);
    t_i3 = idx.t(ii,3);
    t_i4 = idx.t(ii,4);

    % t_{i1}: scheduled robot/waiting operation associated with module i
    Pre(idx.pr,t_i1) = 1;
    Post(p_i1,t_i1) = 1;

    % t_{i2}: internal processing or waiting operation in module i
    Pre(p_i1,t_i2) = 1;
    Post(p_i2,t_i2) = 1;

    % t_{i3}: after-processing transition using p_{i2} and p_{i4}
    Pre(p_i2,t_i3) = 1;
    Pre(p_i4,t_i3) = 1;

    if i < n
        % output to the ready place of the next module
        Post(idx.p(i+2,3),t_i3) = 1;   % p_{(i+1)3}
    else
        % after the last module, output to p_{03}
        Post(p03,t_i3) = 1;
    end

    % t_{i4}: robot-transfer operation after local processing
    Pre(p_i3,t_i4) = 1;
    Post(p_i4,t_i4) = 1;
    Post(idx.pr,t_i4) = 1;
end

%% ============================================================
% Initial marking
%
% M0 = p_{04} + p_r
%% ============================================================

M0 = zeros(numP,1);
M0(p04) = 1;
M0(idx.pr) = 1;

%% ============================================================
% Labels
%
% For n=2:
%   t_{01}: a
%   t_{14}: b
%   t_{24}: c
%   t_{04}: d
%
% All other transitions are unobservable.
%% ============================================================

labels = cell(1,numT);

% Initialize all transitions as unobservable
for i = 0:n
    for j = 1:4
        labels{idx.t(i+1,j)} = 'eps';
    end
end

if n == 2
    labels{idx.t(1,1)} = 'a';   % t_{01}
    labels{idx.t(2,4)} = 'b';   % t_{14}
    labels{idx.t(3,4)} = 'c';   % t_{24}
    labels{idx.t(1,4)} = 'd';   % t_{04}
else
    labels{idx.t(1,1)} = 'a';   % t_{01}

    for i = 1:n
        labels{idx.t(i+1,4)} = sprintf('b%d',i);  % t_{i4}
    end

    labels{idx.t(1,4)} = 'd';   % t_{04}
end

%% ============================================================
% Nominal time intervals I0
%
% The intervals are selected to avoid premature saturation of
% reachable timed behavior when n increases. In particular,
% robot-related transitions t_{i1} are assigned sufficiently
% large upper bounds so that high-index modules are not
% suppressed by low-index transitions under strong semantics.
%% ============================================================

I0 = zeros(numT,2);

for i = 0:n
    ii = i + 1;

    % t_{i1}: scheduled/robot-related operation
    % Wide upper bound to prevent high-index t_{i1} from being
    % permanently suppressed by low-index enabled transitions.
    I0(idx.t(ii,1),:) = [1 + 0.05*i, 30 + 0.05*i];

    % t_{i2}: processing/internal operation
    if i == 0
        I0(idx.t(ii,2),:) = [2, 5];
    else
        I0(idx.t(ii,2),:) = [18 + 0.2*i, 28 + 0.2*i];
    end

    % t_{i3}: waiting/ready operation
    if i == 0
        I0(idx.t(ii,3),:) = [1, 4];
    else
        I0(idx.t(ii,3),:) = [0, 6 + 0.05*i];
    end

    % t_{i4}: robot-transfer / return operation
    I0(idx.t(ii,4),:) = [2 + 0.05*i, 8 + 0.05*i];
end

%% ============================================================
% Attack alpha_1: robot-speed attack
%
% The robot-related observable operations are mildly delayed.
% For n=2, affected transitions:
%   t_{01}, t_{14}, t_{24}, t_{04}.
%% ============================================================

I1 = I0;

if n == 2
    I1(idx.t(1,1),:) = I0(idx.t(1,1),:) + [1,2];   % t_{01}
    I1(idx.t(2,4),:) = I0(idx.t(2,4),:) + [1,2];   % t_{14}
    I1(idx.t(3,4),:) = I0(idx.t(3,4),:) + [1,2];   % t_{24}
    I1(idx.t(1,4),:) = I0(idx.t(1,4),:) + [1,2];   % t_{04}
else
    I1(idx.t(1,1),:) = I0(idx.t(1,1),:) + [1,2];   % t_{01}

    for i = 1:n
        I1(idx.t(i+1,4),:) = I0(idx.t(i+1,4),:) + [1,2]; % t_{i4}
    end

    I1(idx.t(1,4),:) = I0(idx.t(1,4),:) + [1,2];   % t_{04}
end

%% ============================================================
% Attack alpha_2: processing-time compression attack
%
% The internal processing operations in processing modules are shortened.
% Vulnerable transitions:
%   t_{i2}, i=1,...,n.
%
% For n=2:
%   t_{12}, t_{22}.
%% ============================================================

I2 = I0;

for i = 1:n
    ii = i + 1;

    oldL = I0(idx.t(ii,2),1);
    oldU = I0(idx.t(ii,2),2);

    newL = max(1, oldL - 3);
    newU = max(newL + 1, oldU - 3);

    I2(idx.t(ii,2),:) = [newL,newU];
end

%% ============================================================
% Attack alpha_3: waiting-time manipulation attack
%
% The waiting/ready operations are delayed.
% Vulnerable transitions:
%   t_{i3}, i=0,1,...,n.
%
% For n=2:
%   t_{03}, t_{13}, t_{23}.
%% ============================================================

I3 = I0;

for i = 0:n
    ii = i + 1;

    I3(idx.t(ii,3),:) = I0(idx.t(ii,3),:) + [1,3];
end

%% ============================================================
% Build TLPNs
%% ============================================================

G0.Pre = Pre;
G0.Post = Post;
G0.M0 = M0;
G0.labels = labels;
G0.I = I0;

G1 = G0;
G1.I = I1;

G2 = G0;
G2.I = I2;

G3 = G0;
G3.I = I3;

G_list = {G0,G1,G2,G3};

attackNames = { ...
    'alpha_0: no attack', ...
    'alpha_1: robot-speed attack', ...
    'alpha_2: processing-time compression attack', ...
    'alpha_3: waiting-time manipulation attack'};

%% ============================================================
% Meta information
%% ============================================================

meta.n = n;
meta.numSteps = numSteps;
meta.numPlaces = numP;
meta.numTransitions = numT;
meta.idx = idx;

meta.placeNames = cell(1,numP);
for i = 0:n
    for j = 1:4
        meta.placeNames{idx.p(i+1,j)} = sprintf('p_%d%d',i,j);
    end
end
meta.placeNames{idx.pr} = 'p_r';

meta.transitionNames = cell(1,numT);
for i = 0:n
    for j = 1:4
        meta.transitionNames{idx.t(i+1,j)} = sprintf('t_%d%d',i,j);
    end
end

meta.labels = labels;
meta.initialMarkingDescription = 'M0 = p_04 + p_r';

if n == 2
    meta.observableTransitionIndices = [ ...
        idx.t(1,1), ...  % t_{01}
        idx.t(2,4), ...  % t_{14}
        idx.t(3,4), ...  % t_{24}
        idx.t(1,4)  ...  % t_{04}
    ];
else
    meta.observableTransitionIndices = idx.t(1,1);  % t_{01}

    for i = 1:n
        meta.observableTransitionIndices = [ ...
            meta.observableTransitionIndices, idx.t(i+1,4)];
    end

    meta.observableTransitionIndices = [ ...
        meta.observableTransitionIndices, idx.t(1,4)];
end

meta.unobservableTransitionIndices = setdiff(1:numT, meta.observableTransitionIndices);

meta.observableTransitions = meta.transitionNames(meta.observableTransitionIndices);
meta.unobservableTransitions = meta.transitionNames(meta.unobservableTransitionIndices);

meta.vulnerableTransitions.alpha1 = meta.transitionNames(meta.observableTransitionIndices);

meta.vulnerableTransitions.alpha2 = cell(1,n);
for i = 1:n
    meta.vulnerableTransitions.alpha2{i} = meta.transitionNames{idx.t(i+1,2)};
end

meta.vulnerableTransitions.alpha3 = cell(1,n+1);
for i = 0:n
    meta.vulnerableTransitions.alpha3{i+1} = meta.transitionNames{idx.t(i+1,3)};
end

meta.attackNames = attackNames;

end