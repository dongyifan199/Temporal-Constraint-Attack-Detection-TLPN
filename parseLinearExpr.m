function expr = parseLinearExpr(str, varMap, nVars)
% Parse linear expressions such as:
%   3
%   Delta_1_0
%   5-Delta_3_1
%   Delta_1_0+Delta_2_1
%   2*Delta_1_0-3

str = char(str);
str = strtrim(str);
str = strrep(str, ' ', '');

expr.const = 0;
expr.coeff = zeros(1, nVars);

if isempty(str)
    return;
end

% Normalize unary sign.
if str(1) ~= '+' && str(1) ~= '-'
    str = ['+', str];
end

tokens = regexp(str, '([+-])([^+-]+)', 'tokens');

for i = 1:numel(tokens)

    signChar = tokens{i}{1};
    term = tokens{i}{2};

    if strcmp(signChar, '-')
        sgn = -1;
    else
        sgn = 1;
    end

    if isempty(term)
        continue;
    end

    % Variable term possibly with coefficient.
    if contains(term, '*')
        p = split(term, '*');
        coeffVal = str2double(p{1});
        varName = char(p{2});

        if ~isKey(varMap, varName)
            error('Unknown variable name: %s', varName);
        end

        idx = varMap(varName);
        expr.coeff(idx) = expr.coeff(idx) + sgn * coeffVal;

    elseif isKey(varMap, term)
        idx = varMap(term);
        expr.coeff(idx) = expr.coeff(idx) + sgn;

    else
        val = str2double(term);

        if isnan(val)
            error('Cannot parse linear term: %s in expression %s', term, str);
        end

        expr.const = expr.const + sgn * val;
    end
end

end

