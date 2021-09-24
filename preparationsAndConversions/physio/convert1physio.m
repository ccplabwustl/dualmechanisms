% code written by Joset A. Etzel (jetzel@wustl.edu) https://sites.wustl.edu/dualmechanisms   https://sites.wustl.edu/ccplab/

% https://opensource.org/licenses/BSD-3-Clause 
% Copyright 2018, Cognitive Control & Psychopathology Lab, Psychological & Brain Sciences, Washington University in St. Louis (USA)
% Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
% 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
% 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the 
%    documentation and/or other materials provided with the distribution.
% 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this
%    software without specific prior written permission.
% 
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
% TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR 
% CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, 
% PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
% OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF 
% THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This file should not need modification; the function is called from template_convert.m. 

function [y] = convert1physio(i, uuids, endname, runnames, inpath, outpath, subid)
% do the actual physio file conversion. matlab will print out info while it
% works: file summary, which physio types are present, etc.
y = ['did ' runnames{i}];


if exist([inpath uuids(i,:) endname], 'file') == 2
    physio = readCMRRPhysio([inpath uuids(i,:)]);
    outname = [outpath subid '_' runnames{i} '_physio.csv'];
    foundcombo = 0;    % reset flag for if found the right mix of fields.
    
    % write the physio as a csv, depending on which fields are present
    if isequal(foundcombo,0) && isfield(physio, 'ACQ') && isfield(physio, 'EXT') && isfield(physio, 'RESP') && isfield(physio, 'PULS')
        foundcombo = 1;   % found match, so reset flag
        if size(physio.ACQ,1) > 500000
            inds = find(physio.ACQ);   % find non-zero entry indices
            outtbl = [physio.ACQ(inds) physio.EXT(inds) physio.RESP(inds) physio.PULS(inds)];
        else
            outtbl = [physio.ACQ physio.EXT physio.RESP physio.PULS];
        end
        fid = fopen(outname, 'w');
        fprintf(fid, 'physio.ACQ, physio.EXT, physio.RESP, physio.PULS\n');
        fclose(fid);
        dlmwrite(outname, outtbl, '-append');
    end
    if isequal(foundcombo,0) && isfield(physio, 'ACQ') && isfield(physio, 'RESP') && isfield(physio, 'PULS')   % same, no EXT
        foundcombo = 1;   % found match, so reset flag
        if size(physio.ACQ,1) > 500000
            inds = find(physio.ACQ);   % find non-zero entry indices
            outtbl = [physio.ACQ(inds) physio.RESP(inds) physio.PULS(inds)];
        else
            outtbl = [physio.ACQ physio.RESP physio.PULS];
        end
        fid = fopen(outname, 'w');
        fprintf(fid, 'physio.ACQ, physio.RESP, physio.PULS\n');
        fclose(fid);
        dlmwrite(outname, outtbl, '-append');
    end
    
    % no PULS
    if isequal(foundcombo,0) && isfield(physio, 'ACQ') && isfield(physio, 'EXT') && isfield(physio, 'RESP')
        foundcombo = 1;   % found match, so reset flag
        if size(physio.ACQ,1) > 500000
            inds = find(physio.ACQ);   % find non-zero entry indices
            outtbl = [physio.ACQ(inds) physio.EXT(inds) physio.RESP(inds)];
        else
            outtbl = [physio.ACQ physio.EXT physio.RESP];
        end
        fid = fopen(outname, 'w');
        fprintf(fid, 'physio.ACQ, physio.EXT, physio.RESP\n');
        fclose(fid);
        dlmwrite(outname, outtbl, '-append');
    end
    if isequal(foundcombo,0) && isfield(physio, 'ACQ') && isfield(physio, 'RESP')       % same, no EXT
        foundcombo = 1;   % found match, so reset flag
        if size(physio.ACQ,1) > 500000
            inds = find(physio.ACQ);   % find non-zero entry indices
            outtbl = [physio.ACQ(inds) physio.RESP(inds)];
        else
            outtbl = [physio.ACQ physio.RESP];
        end
        fid = fopen(outname, 'w');
        fprintf(fid, 'physio.ACQ, physio.RESP\n');
        fclose(fid);
        dlmwrite(outname, outtbl, '-append');
    end
    
    % no RESP
    if isequal(foundcombo,0) && isfield(physio, 'ACQ') && isfield(physio, 'EXT') && isfield(physio, 'PULS')
        foundcombo = 1;   % found match, so reset flag
        if size(physio.ACQ,1) > 500000
            inds = find(physio.ACQ);   % find non-zero entry indices
            outtbl = [physio.ACQ(inds) physio.EXT(inds) physio.PULS(inds)];
        else
            outtbl = [physio.ACQ physio.EXT physio.PULS];
        end
        fid = fopen(outname, 'w');
        fprintf(fid, 'physio.ACQ, physio.EXT, physio.PULS\n');
        fclose(fid);
        dlmwrite(outname, outtbl, '-append');
    end
    if isequal(foundcombo,0) && isfield(physio, 'ACQ') && isfield(physio, 'PULS')      % same, no EXT
        foundcombo = 1;   % found match, so reset flag
        if size(physio.ACQ,1) > 500000
            inds = find(physio.ACQ);   % find non-zero entry indices
            outtbl = [physio.ACQ(inds) physio.PULS(inds)];
        else
            outtbl = [physio.ACQ physio.PULS];
        end
        fid = fopen(outname, 'w');
        fprintf(fid, 'physio.ACQ, physio.PULS\n');
        fclose(fid);
        dlmwrite(outname, outtbl, '-append');
    end
    
    if isequal(foundcombo, 0)
        warning(['did not find proper combination of fields: ', [inpath uuids(i,:) endname]]);
        warning(['file should be for ' runnames{i}]);
        y = ['did not find proper combination of fields: ', [inpath uuids(i,:) endname]];
    end
else
    warning(['file does not exist: ', [inpath uuids(i,:) endname]]);
    warning(['missing file should be for ' runnames{i}]);
    y = ['file does not exist: ', [inpath uuids(i,:) endname]];
end
end