function hk = findHByAttack(H, attackInternalIndex)
% attackInternalIndex = 1 corresponds to alpha_0.
% H(k).component is MATLAB index if constructADG.m is used.
% H(k).attackIndex is paper index.

hk = [];

for k = 1:numel(H)

    if isfield(H(k), 'component')
        if H(k).component == attackInternalIndex
            hk = H(k);
            return;
        end
    elseif isfield(H(k), 'attackIndex')
        if H(k).attackIndex == attackInternalIndex - 1
            hk = H(k);
            return;
        end
    end
end

end