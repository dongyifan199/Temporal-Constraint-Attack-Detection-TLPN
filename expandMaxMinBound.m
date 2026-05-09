function terms = expandMaxMinBound(str, type)

str = strtrim(str);

prefix = [type, '{'];

if startsWith(str, prefix) && endsWith(str, '}')
    inside = str(length(prefix)+1:end-1);
    terms = splitTopLevelList(inside);
else
    terms = {str};
end

end