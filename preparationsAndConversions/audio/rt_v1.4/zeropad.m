function pad_name = zeropad(filename, n)

format = strcat('%s%0', num2str(n),'s');
[newname, id] = get_id(filename);    
pad_name = sprintf(format, newname, id);


end