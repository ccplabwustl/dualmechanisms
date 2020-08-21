function [newname, id] = get_id(name)

low_str     = lower(name);
cell_str    = strsplit(low_str, '-');

% filename
cell_part1  = cell_str(1:end-1);
newname        = strcat(cell_part1, '_');
newname        = strcat(newname{:});

% file ID number
end_str = cell_str{end};
id      = strsplit(end_str, {'.', '_'}, 'CollapseDelimiters', true);
id      = id{1};

end





