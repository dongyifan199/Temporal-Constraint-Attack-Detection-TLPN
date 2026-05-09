%An example
OMSC1 = constructOMSCG(MSCG1);
OMSC2 = constructOMSCG(MSCG2);
ADG = constructADG({OMSC1, OMSC2});

fprintf('\n===== ADG Vertices =====\n');
for i = 1:numel(ADG.V)
    tuple = ADG.V(i).tuple;

    fprintf('vd%d = (', i-1);
    for j = 1:numel(tuple)
        fprintf('v%d%d', tuple(j)-1, j-1);
        if j < numel(tuple)
            fprintf(', ');
        end
    end
    fprintf(')\n');
end

fprintf('\n===== ADG Edges with Full H =====\n');
for i = 1:numel(ADG.E)
    e = ADG.E(i);

    fprintf('\n');
    fprintf('e%d = (vd%d, %s, H, vd%d)\n', ...
        i, e.source-1, e.label, e.target-1);

    fprintf('    H = {\n');

    for k = 1:numel(e.H)
        hk = e.H(k);

        fprintf('        H^{%d} = (Delta = %s,\n', ...
            hk.attackIndex, hk.Delta);

        fprintf('                 CO = {');

        if isempty(hk.CO)
            fprintf(' empty ');
        else
            for q = 1:numel(hk.CO)
                fprintf('%s', hk.CO{q});
                if q < numel(hk.CO)
                    fprintf(', ');
                end
            end
        end

        fprintf('})');

        if k < numel(e.H)
            fprintf(',\n');
        else
            fprintf('\n');
        end
    end

    fprintf('    }\n');

    fprintf('    local OMSCG edges: ');
    for k = 1:numel(e.H)
        fprintf('alpha_%d:e_o%d ', ...
            e.H(k).attackIndex, e.H(k).OMSC_edge);
    end
    fprintf('\n');
end