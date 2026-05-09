function [G_list, attackNames, meta] = makeS3PRTLPNBenchmark(k1, k2, r1, r2)
% makeS3PRTLPNBenchmark
% A TLPN benchmark based on an S^3PR shared-resource system.
%
% S^3PR: Systems of Simple Sequential Processes with Shared Resources.
%
% Places:
%   p1,p2,p3: sequential process 1
%   p4,p5,p6: sequential process 2
%   p7,p8   : shared resources
%
% Transitions:
%   t1,t2,t3: transitions of process 1
%   t4,t5,t6: transitions of process 2
%
% Initial marking:
%   M0 = k1*p3 + k2*p6 + r1*p7 + r2*p8.
%
% Attack set:
%   alpha_0: no attack
%   alpha_1: mild resource-delay attack
%   alpha_2: mild premature-completion attack
%
% Labeling:
%   l(t1)=a, l(t3)=b,
%   l(t4)=c, l(t6)=d,
%   l(t2)=l(t5)=eps.

if nargin < 1
    k1 = 1;
end
if nargin < 2
    k2 = 1;
end
if nargin < 3
    r1 = 1;
end
if nargin < 4
    r2 = 1;
end

if k1 < 1 || k2 < 1 || r1 < 1 || r2 < 1
    error('k1, k2, r1, and r2 must be positive integers.');
end

%% ============================================================
% Places and transitions
%% ============================================================

numP = 8;
numT = 6;

% Place indices
p1 = 1;
p2 = 2;
p3 = 3;
p4 = 4;
p5 = 5;
p6 = 6;
p7 = 7;
p8 = 8;

% Transition indices
t1 = 1;
t2 = 2;
t3 = 3;
t4 = 4;
t5 = 5;
t6 = 6;

Pre  = zeros(numP,numT);
Post = zeros(numP,numT);

%% ============================================================
% Topology
%
% Process 1:
%   p3 + p7 --t1--> p1
%   p1 + p8 --t2--> p2 + p7
%   p2      --t3--> p3 + p8
%
% Process 2:
%   p6 + p8 --t4--> p4
%   p4 + p7 --t5--> p5 + p8
%   p5      --t6--> p6 + p7
%% ============================================================

% t1: process 1 starts and acquires resource p7
Pre(p3,t1) = 1;
Pre(p7,t1) = 1;
Post(p1,t1) = 1;

% t2: process 1 switches from resource p7 to p8
Pre(p1,t2) = 1;
Pre(p8,t2) = 1;
Post(p2,t2) = 1;
Post(p7,t2) = 1;

% t3: process 1 completes and releases resource p8
Pre(p2,t3) = 1;
Post(p3,t3) = 1;
Post(p8,t3) = 1;

% t4: process 2 starts and acquires resource p8
Pre(p6,t4) = 1;
Pre(p8,t4) = 1;
Post(p4,t4) = 1;

% t5: process 2 switches from resource p8 to p7
Pre(p4,t5) = 1;
Pre(p7,t5) = 1;
Post(p5,t5) = 1;
Post(p8,t5) = 1;

% t6: process 2 completes and releases resource p7
Pre(p5,t6) = 1;
Post(p6,t6) = 1;
Post(p7,t6) = 1;

%% ============================================================
% Initial marking
%
% M0 = k1*p3 + k2*p6 + r1*p7 + r2*p8
%% ============================================================

M0 = zeros(numP,1);
M0(p3) = k1;
M0(p6) = k2;
M0(p7) = r1;
M0(p8) = r2;

%% ============================================================
% Labels
%
% a: process 1 starts
% b: process 1 completes
% c: process 2 starts
% d: process 2 completes
% eps: internal resource-switching operations
%% ============================================================

labels = cell(1,numT);

labels{t1} = 'a';     % process 1 starts
labels{t2} = 'eps';   % internal resource switching of process 1
labels{t3} = 'b';     % process 1 completes

labels{t4} = 'c';     % process 2 starts
labels{t5} = 'eps';   % internal resource switching of process 2
labels{t6} = 'd';     % process 2 completes

%% ============================================================
% Nominal firing intervals: alpha_0
%% ============================================================

I0 = zeros(numT,2);

I0(t1,:) = [2,4.99];   % process 1 starts
I0(t2,:) = [4,6.99];   % internal resource switching of process 1
I0(t3,:) = [2,3.99];   % process 1 completes

I0(t4,:) = [3,5.99];   % process 2 starts
I0(t5,:) = [5,7.99];   % internal resource switching of process 2
I0(t6,:) = [2,4.99];   % process 2 completes

%% ============================================================
% alpha_1: mild resource-delay attack
%
% Vulnerable transitions: t2,t5
% The internal shared-resource switching operations are slightly delayed.
%% ============================================================

I1 = I0;
I1(t2,:) = [5,7.99];
I1(t5,:) = [6,8.99];

%% ============================================================
% alpha_2: mild premature-completion attack
%
% Vulnerable transitions: t2,t5
% The internal shared-resource switching operations are slightly shortened.
%% ============================================================

I2 = I0;
I2(t2,:) = [3,5.99];
I2(t5,:) = [4,6.99];

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

G_list = {G0,G1,G2};

attackNames = { ...
    'alpha_0: no attack', ...
    'alpha_1: mild resource-delay attack', ...
    'alpha_2: mild premature-completion attack'};

%% ============================================================
% Meta information
%% ============================================================

meta.k1 = k1;
meta.k2 = k2;
meta.r1 = r1;
meta.r2 = r2;

meta.numPlaces = numP;
meta.numTransitions = numT;

meta.placeNames = {'p1','p2','p3','p4','p5','p6','p7','p8'};
meta.placeMeaning = { ...
    'operation stage 1 of process 1', ...
    'operation stage 2 of process 1', ...
    'idle/input buffer of process 1', ...
    'operation stage 1 of process 2', ...
    'operation stage 2 of process 2', ...
    'idle/input buffer of process 2', ...
    'shared resource 1', ...
    'shared resource 2'};

meta.transitionNames = {'t1','t2','t3','t4','t5','t6'};
meta.transitionMeaning = { ...
    'process 1 starts and acquires resource p7', ...
    'process 1 switches resource from p7 to p8', ...
    'process 1 completes and releases resource p8', ...
    'process 2 starts and acquires resource p8', ...
    'process 2 switches resource from p8 to p7', ...
    'process 2 completes and releases resource p7'};

meta.labels = labels;

meta.observableTransitionIndices = [t1,t3,t4,t6];
meta.unobservableTransitionIndices = [t2,t5];

meta.vulnerableTransitions.alpha1 = {'t2','t5'};
meta.vulnerableTransitions.alpha2 = {'t2','t5'};

meta.initialMarkingDescription = sprintf( ...
    'M0 = %d*p3 + %d*p6 + %d*p7 + %d*p8', k1, k2, r1, r2);

meta.attackNames = attackNames;

end