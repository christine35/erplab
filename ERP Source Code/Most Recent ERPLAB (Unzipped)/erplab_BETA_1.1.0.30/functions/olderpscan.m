% Author: Javier Lopez-Calderon
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2009

%b8d3721ed219e65100184c6b95db209bb8d3721ed219e65100184c6b95db209b
%
% ERPLAB Toolbox
% Copyright � 2007 The Regents of the University of California
% Created by Javier Lopez-Calderon and Steven Luck
% Center for Mind and Brain, University of California, Davis,
% javlopez@ucdavis.edu, sjluck@ucdavis.edu
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.

function [ERP conti serror] = olderpscan(ERP, menup)

serror = 0;
conti  = 1;

if nargin<1
        help  olderpscan
        return
end
if nargin<2
        menup = 1;
end
try
        dataversion = ERP.version;
catch
        try
                dataversion = ERP.EVENTLIST.version;
        catch
                dataversion = '0';
        end
end

%
% Split data version numbering
%
[pspliter vdigits] = regexp(dataversion, '\.','match','split');

if length(vdigits)==3
        dmayor       = str2num(vdigits{1});
        dminor       = 0;
        dformat      = 0;
        dmaintenance = str2num(vdigits{3});
elseif length(vdigits)==4
        dmayor       = str2num(vdigits{1});
        dminor       = str2num(vdigits{2});
        dformat      = str2num(vdigits{3});
        dmaintenance = str2num(vdigits{4});
elseif length(vdigits)>4
        msgboxText{1} =  sprintf('The version of your erpset: %s does not match with the ERPLAB''s version numbering A.B.C.D.', dataversion);
        title = 'ERPLAB: UNKNOWN DATA VERSION';
        errorfound(msgboxText, title)
        serror = 1;
        return
else
        % unknow or very ooooold version, when Javier used to be shy
        dmayor       = 0;
        dminor       = 0;
        dformat      = -1;
        dmaintenance = 0;
end

%
% Split ERPLAB current version numbering
%
cversion     = geterplabversion; % current erplab version
[pspliter vdigits] = regexp(cversion, '\.','match','split');
cmayor       = str2num(vdigits{1}); % A
cminor       = str2num(vdigits{2}); % B
cformat      = str2num(vdigits{3}); % C
cmaintenance = str2num(vdigits{4}); % D

%
% Greater allowed version number :  999999999.999999999.999999999.999999999
%
dvnum = 1E30*dmayor + 1E20*dminor + 1E10*dformat + dmaintenance;
cvnum = 1E30*cmayor + 1E20*cminor + 1E10*cformat + cmaintenance;

if cvnum~=dvnum

        if cvnum>dvnum
                wordcomp = 'an older';
        else
                wordcomp = 'a newer';
        end

        title    = ['ERPLAB: erp_loaderp() for version: ' dataversion] ;
        cerpname = ERP.filename;

        if isempty(cerpname)
                cerpname = ERP.erpname;
                if iscell(cerpname)
                        cerpname = cerpname{1};
                end
        end

        if cformat~= dformat % different ERP structure was found
                if menup == 1;
                        question{1} = sprintf('WARNING: Erpset %s was created from %s ERPLAB version', cerpname, wordcomp);
                        question{2} = 'ERPLAB will try to make it compatible with the current version.';
                        question{3} = 'Do you want to continue?';

                        button = askquest(question, title);

                        if ~strcmpi(button,'yes')
                                disp('User selected Cancel')
                                conti = 0;
                                return
                        end
                else
                        fprintf('\nWARNING: Erpset %s was created from %s ERPLAB version.\n', cerpname, wordcomp);
                        fprintf('ERPLAB will attempt to update the ERP structure...\n\n');
                end
        else
                fprintf('\nWARNING: Erpset %s was created from %s ERPLAB version.\n', cerpname, wordcomp);
        end

        ERP = old2newerp(ERP, dataversion);
        %
        % Version 1.0.0
        %
        [ERP serror] = sorterpstruct(ERP);
        ERP.filename = '';
        ERP.filepath = '';
        ERP.saved    = 'no';
else
        % all right
        return
end