function [G_list, attackNames, meta] = makeParamWaferTLPNBenchmark(n)
% makeParamWaferTLPNBenchmark
% Parameterized wafer processing TLPN benchmark.
%
% For n processing modules:
%   |P| = 3n + 3
%   |T| = 3n + 2
%
% When n = 2:
%   |P| = 9, |T| = 8.
%
% For n = 2, the observable labels are:
%   t1: a
%   t4: b
%   t7: c
%   t8: d
%
% Output:
%   G_list{1}: alpha_0, no attack
%   G_list{2}: alpha_1, robot-speed attack
%   G_list{3}: alpha_2, processing-recipe compression attack
%   G_list{4}: alpha_3, waiting-time manipulation attack

if nargin < 1
    n = 2;
end

if n < 1
    error('n must be a positive integer.');
end

%% ============================================================
% Place indexing
%
% For n = 2, the place order is:
%   1:p0, 2:p1, 3:p2, 4:p3, 5:p4, 6:p5, 7:r, 8:q1, 9:q2
%
% General order:
%   p0,
%   proc_1, comp_1, ..., proc_n, comp_n,
%   pf,
%   r,
%   q_1,...,q_n
%% ============================================================

idx.p0 = 1;

idx.proc = zeros(1,n);
idx.comp = zeros(1,n);

for i = 1:n
    idx.proc(i) = 2*i;       % processing place of module i
    idx.comp(i) = 2*i + 1;   % completed place of module i
end

idx.pf = 2*n + 2;            % returned/finished wafer place
idx.r  = 2*n + 3;            % robot available place
idx.q  = (2*n + 4):(3*n + 3);

numP = 3*n + 3;

%% ============================================================
% Transition indexing
%
% For n = 2, the transition order is:
%   1:t1 = s0
%   2:t2 = x1
%   3:t3 = y1
%   4:t4 = s1
%   5:t5 = x2
%   6:t6 = y2
%   7:t7 = s2
%   8:t8 = sf
%
% General:
%   s0,
%   x_i, y_i, s_i for i = 1,...,n,
%   sf
%% ============================================================

idx.s0 = 1;

idx.x = zeros(1,n);   % processing completion
idx.y = zeros(1,n);   % waiting/ready
idx.s = zeros(1,n);   % robot transfer/unload

for i = 1:n
    idx.x(i) = 3*(i-1) + 2;
    idx.y(i) = 3*(i-1) + 3;
    idx.s(i) = 3*(i-1) + 4;
end

idx.sf = 3*n + 2;

numT = 3*n + 2;

Pre  = zeros(numP, numT);
Post = zeros(numP, numT);

%% ============================================================
% s0: p0 + r -> proc_1 + r
%% ============================================================

Pre(idx.p0, idx.s0) = 1;
Pre(idx.r,  idx.s0) = 1;

Post(idx.proc(1), idx.s0) = 1;
Post(idx.r,       idx.s0) = 1;

%% ============================================================
% For each module i:
%   x_i: proc_i -> comp_i
%   y_i: comp_i -> q_i
%   s_i: q_i + r -> proc_{i+1} + r, if i < n
%        q_n + r -> pf + r, if i = n
%% ============================================================

for i = 1:n

    % x_i: processing completion in module i
    Pre(idx.proc(i), idx.x(i)) = 1;
    Post(idx.comp(i), idx.x(i)) = 1;

    % y_i: waiting/ready after module i
    Pre(idx.comp(i), idx.y(i)) = 1;
    Post(idx.q(i), idx.y(i)) = 1;

    % s_i: robot transfer or unloading
    Pre(idx.q(i), idx.s(i)) = 1;
    Pre(idx.r,    idx.s(i)) = 1;

    if i < n
        Post(idx.proc(i+1), idx.s(i)) = 1;
    else
        Post(idx.pf, idx.s(i)) = 1;
    end

    Post(idx.r, idx.s(i)) = 1;
end

%% ============================================================
% sf: pf -> p0
%% ============================================================

Pre(idx.pf, idx.sf) = 1;
Post(idx.p0, idx.sf) = 1;

%% ============================================================
% Initial marking
%% ============================================================

M0 = zeros(numP,1);
M0(idx.p0) = 1;
M0(idx.r)  = 1;

%% ============================================================
% Labels
%
% For n = 2:
%   s0 -> a
%   s1 -> b
%   s2 -> c
%   sf -> d
%
% For n > 2:
%   s0 -> a
%   s_i -> b_i, i = 1,...,n
%   sf -> d
%% ============================================================

labels = cell(1,numT);

labels{idx.s0} = 'a';

for i = 1:n
    labels{idx.x(i)} = 'eps';
    labels{idx.y(i)} = 'eps';

    if n == 2
        if i == 1
            labels{idx.s(i)} = 'b';
        elseif i == 2
            labels{idx.s(i)} = 'c';
        end
    else
        labels{idx.s(i)} = sprintf('b%d', i);
    end
end

labels{idx.sf} = 'd';

%% ============================================================
% Nominal intervals I0
%
% For n = 2, transition order:
%   t1=s0: [1,3]
%   t2=x1: [20,30]
%   t3=y1: [0,5]
%   t4=s1: [3,6]
%   t5=x2: [25,38]
%   t6=y2: [0,6]
%   t7=s2: [2,5]
%   t8=sf: [1,2]
%% ============================================================

I0 = zeros(numT,2);

% s0: loading
I0(idx.s0,:) = [1, 3];

for i = 1:n

    % x_i: processing time in module i
    % For n=2:
    %   x1: [20,30]
    %   x2: [25,38]
    I0(idx.x(i),:) = [15 + 5*i, 22 + 8*i];

    % y_i: waiting/ready time after processing
    % For n=2:
    %   y1: [0,5]
    %   y2: [0,6]
    I0(idx.y(i),:) = [0, 4 + i];

    % s_i: robot transfer/unload
    % For n=2:
    %   s1: [3,6]
    %   s2: [2,5]
    if i < n
        I0(idx.s(i),:) = [2 + mod(i,2), 5 + mod(i,2)];
    else
        I0(idx.s(i),:) = [2, 5];
    end
end

% sf: cycle completion/reset
I0(idx.sf,:) = [1, 2];

%% ============================================================
% alpha_1: robot-speed attack
%
% Robot-related operations are delayed.
%
% For n=2:
%   t1=s0: [2,5]
%   t4=s1: [6,10]
%   t7=s2: [4,8]
%% ============================================================

I1 = I0;

I1(idx.s0,:) = [2, 5];

for i = 1:n
    if i < n
        I1(idx.s(i),:) = I0(idx.s(i),:) + [3, 4];
    else
        I1(idx.s(i),:) = I0(idx.s(i),:) + [2, 3];
    end
end

%% ============================================================
% alpha_2: processing-recipe compression attack
%
% Processing intervals are shortened.
%
% For n=2:
%   t2=x1: [12,18]
%   t5=x2: [16,24]
%% ============================================================

I2 = I0;

for i = 1:n
    I2(idx.x(i),:) = [8 + 4*i, 12 + 6*i];
end

%% ============================================================
% alpha_3: waiting-time manipulation attack
%
% Waiting/ready intervals are increased.
%
% For n=2:
%   t3=y1: [4,12]
%   t6=y2: [5,14]
%% ============================================================

I3 = I0;

for i = 1:n
    I3(idx.y(i),:) = [3 + i, 10 + 2*i];
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

G_list = {G0, G1, G2, G3};

attackNames = { ...
    'alpha_0: no attack', ...
    'alpha_1: robot-speed attack', ...
    'alpha_2: processing-recipe compression attack', ...
    'alpha_3: waiting-time manipulation attack'};

%% ============================================================
% Meta information
%% ============================================================

meta.n = n;
meta.numPlaces = numP;
meta.numTransitions = numT;
meta.idx = idx;

meta.placeNames = cell(1,numP);
meta.placeMeaning = cell(1,numP);

meta.placeNames{idx.p0} = 'p0';
meta.placeMeaning{idx.p0} = 'wafer available in the loadlock';

for i = 1:n
    meta.placeNames{idx.proc(i)} = sprintf('p%d', 2*i-1);
    meta.placeMeaning{idx.proc(i)} = sprintf('wafer being processed in module %d', i);

    meta.placeNames{idx.comp(i)} = sprintf('p%d', 2*i);
    meta.placeMeaning{idx.comp(i)} = sprintf('wafer completed processing in module %d', i);
end

meta.placeNames{idx.pf} = sprintf('p%d', 2*n+1);
meta.placeMeaning{idx.pf} = 'wafer returned to the loadlock';

meta.placeNames{idx.r} = 'r';
meta.placeMeaning{idx.r} = 'robot arm available';

for i = 1:n
    meta.placeNames{idx.q(i)} = sprintf('q%d', i);
    if i < n
        meta.placeMeaning{idx.q(i)} = sprintf('wafer ready for transfer from module %d to module %d', i, i+1);
    else
        meta.placeMeaning{idx.q(i)} = sprintf('wafer ready for unloading from module %d', i);
    end
end

meta.transitionNames = cell(1,numT);
meta.transitionMeaning = cell(1,numT);

if n == 2
    for t = 1:numT
        meta.transitionNames{t} = sprintf('t%d', t);
    end
else
    meta.transitionNames{idx.s0} = 's0';
    for i = 1:n
        meta.transitionNames{idx.x(i)} = sprintf('x%d', i);
        meta.transitionNames{idx.y(i)} = sprintf('y%d', i);
        meta.transitionNames{idx.s(i)} = sprintf('s%d', i);
    end
    meta.transitionNames{idx.sf} = 'sf';
end

meta.transitionMeaning{idx.s0} = 'load wafer from loadlock to module 1';

for i = 1:n
    meta.transitionMeaning{idx.x(i)} = sprintf('complete processing in module %d', i);
    meta.transitionMeaning{idx.y(i)} = sprintf('waiting/ready operation after module %d', i);

    if i < n
        meta.transitionMeaning{idx.s(i)} = sprintf('transfer wafer from module %d to module %d', i, i+1);
    else
        meta.transitionMeaning{idx.s(i)} = sprintf('unload wafer from module %d to loadlock', i);
    end
end

meta.transitionMeaning{idx.sf} = 'cycle completion/reset';

meta.labels = labels;

meta.observableTransitionIndices = [idx.s0, idx.s, idx.sf];
meta.unobservableTransitionIndices = [idx.x, idx.y];

meta.observableTransitions = meta.transitionNames(meta.observableTransitionIndices);
meta.unobservableTransitions = meta.transitionNames(meta.unobservableTransitionIndices);

meta.vulnerableTransitions.alpha1 = [{'s0'}, arrayfun(@(i) sprintf('s%d', i), 1:n, 'UniformOutput', false)];
meta.vulnerableTransitions.alpha2 = arrayfun(@(i) sprintf('x%d', i), 1:n, 'UniformOutput', false);
meta.vulnerableTransitions.alpha3 = arrayfun(@(i) sprintf('y%d', i), 1:n, 'UniformOutput', false);

meta.attackNames = attackNames;

end