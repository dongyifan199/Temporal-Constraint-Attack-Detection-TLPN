function [betaSeq, tauSeq] = normalizeObservation(w_a)

if isstruct(w_a)
    betaSeq = w_a.labels;
    tauSeq = w_a.times;
elseif iscell(w_a)
    betaSeq = cell(1, numel(w_a));
    tauSeq = zeros(1, numel(w_a));

    for i = 1:numel(w_a)
        betaSeq{i} = w_a{i}{1};
        tauSeq(i) = w_a{i}{2};
    end
else
    error('Unsupported observation format.');
end

if numel(betaSeq) ~= numel(tauSeq)
    error('The number of labels and times must be equal.');
end

for i = 1:numel(betaSeq)
    if isstring(betaSeq{i})
        betaSeq{i} = char(betaSeq{i});
    end
end

tauSeq = tauSeq(:)';

end
