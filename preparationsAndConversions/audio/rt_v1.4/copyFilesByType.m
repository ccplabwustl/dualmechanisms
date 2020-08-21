function copyFilesByType(dir_origin, dir_destination, filetype)


dir_aux = fullfile(tempdir, 'aux');
[status, message, messageid] = mkdir(dir_aux);

if ~isdir(dir_destination)
    mkdir(dir_destination)
%else
%    error('Folder %s already exists. Will not overwrite.', dir_destination)
end
    

list = dir(fullfile(dir_origin, ['*.' filetype]));

for i = 1:length(list)

    newname = strrep(list(i).name, ' ', '_');    
    status = copyfile(fullfile(dir_origin,list(i).name), fullfile(dir_aux, newname));
    sprintf('Status: %d', status)
    
end

copyfile(fullfile(dir_aux, ['*.' filetype]), dir_destination)
%% empty folder first
delete(fullfile(dir_aux, ['*.' filetype]))
rmdir(dir_aux)

end
