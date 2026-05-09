# Temporal-Constraint-Attack-Detection-TLPN
MATLAB implementation for temporal constraint attack detection in time labeled Petri nets.
## Usage

This repository provides MATLAB code for temporal constraint attack detection in time labeled Petri nets (TLPNs). The implementation includes the construction of modified state class graphs (MSCGs), observable modified state class graphs (OMSCGs), attack detection graphs (ADGs), and attack detection from timed observations.

### 1. Add the code to the MATLAB path

After downloading or cloning this repository, open MATLAB and set the current folder to the root directory of the repository. 
Then run:

```matlab
addpath(genpath(pwd));
```

### 2. Main functions

The main functions are:

- `constructMSCGStrongMerged.m`: constructs the MSCG of a TLPN under strong time semantics.
- `constructOMSCG.m`: constructs the OMSCG from an MSCG.
- `constructADG.m`: constructs the ADG from the OMSCGs under different attack hypotheses.
- `attackDetectionADG.m`: performs attack detection for a given attacked timed observation.

### 3. Wafer processing benchmark

Generate the wafer processing benchmark by running:

```matlab
[G_list, attackNames, meta] = makeWaferTLPNBenchmark_FigModel(2);
```

Run the attack detection example:

```matlab
test_Wafer_FigModel_Detection
```

Run the scalability test for the parameterized wafer processing benchmark:

```matlab
runFigModelBenchmark
```

### 4. S3PR-based shared-resource benchmark

Generate the S3PR-based shared-resource benchmark by running:

```matlab
[G_list, attackNames, meta] = makeS3PRTLPNBenchmark(k1, k2, r1, r2);
```

The initial marking is

```matlab
M0 = k1*p3 + k2*p6 + r1*p7 + r2*p8;
```

where `k1` and `k2` denote the numbers of initial jobs in the two processes, and `r1` and `r2` denote the numbers of available resource units.

Run the token scalability test:

```matlab
runS3PRTokenBenchmark
```

### 5. Example workflow

```matlab
clear; clc;

% Generate the wafer processing benchmark
[G_list, attackNames, meta] = makeWaferTLPNBenchmark_FigModel(2);

% Construct MSCGs and OMSCGs under all attack hypotheses
numModels = numel(G_list);
MSCG_list = cell(1,numModels);
OMSC_list = cell(1,numModels);

for i = 1:numModels
    MSCG_list{i} = constructMSCGStrongMerged(G_list{i}, 3000);
    OMSC_list{i} = constructOMSCG(MSCG_list{i});
end

% Construct the ADG
ADG = constructADG(OMSC_list);

% Define an attacked timed observation
w_a.labels = {'a','b','c','d'};
w_a.times  = [2,12,32,52];

% Perform attack detection
options.verbose = true;
options.tol = 1e-9;

[A, DET] = attackDetectionADG(ADG, w_a, options);

% Display the detected attack types
disp(A);
```

The output `A` gives the set of attack types consistent with the attacked timed observation.

### 6. Notes

- Transition labels equal to `'eps'` are treated as unobservable.
- The input TLPN is represented by `Pre`, `Post`, `M0`, `labels`, and `I`.
- `Pre` and `Post` are the pre- and post-incidence matrices.
- `M0` is the initial marking.
- `labels` stores the transition labels.
- `I` stores the firing time intervals of transitions.
- The parameter `maxNodes` in `constructMSCGStrongMerged(G, maxNodes)` controls the maximum number of MSCG nodes explored. Increase this value if the construction stops too early.
