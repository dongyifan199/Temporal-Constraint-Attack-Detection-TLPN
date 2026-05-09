clearvars -except ADG OMSC0 OMSC1 MSCG0 MSCG1 G0 G1
clc;

% Attacked timed observation:
% w_a = (a,12)(b,17)
w_a.labels = {'a','b'};
w_a.times  = [12,17];

options.verbose = true;
options.tol = 1e-9;

[A, DET] = attackDetectionADG(ADG, w_a, options);

fprintf('\n===== Detection Result =====\n');
fprintf('A = { ');
for i = 1:numel(A)
    fprintf('alpha_%d ', A(i));
end
fprintf('}\n');

fprintf('\n===== Final Candidates =====\n');
for c = 1:numel(DET.finalCandidates)
    cand = DET.finalCandidates{c};

    fprintf('Candidate %d: ADG vertex vd%d, A_v = { ', ...
        c, cand.v - 1);

    for k = 1:numel(cand.A)
        fprintf('alpha_%d ', cand.A(k)-1);
    end

    fprintf('}\n');

    for k = 1:numel(cand.A)
        idx = cand.A(k);

        fprintf('    Constraints for alpha_%d:\n', idx-1);

        phi = cand.Phi{idx};
        for q = 1:numel(phi)
            fprintf('        %s\n', phi{q});
        end
    end
end