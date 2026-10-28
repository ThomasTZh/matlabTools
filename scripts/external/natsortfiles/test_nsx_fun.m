classdef test_nsx_fun < handle
	% Class for comparing actual function output against expected output.
	%
	% (c) 2012-2026 Stephen Cobeldick
	%
	% See also ARBSORT_TEST NATSORT_TEST NATSORTFILES_TEST NATSORTROWS_TEST
	properties
		funHnd % handle to function under test
		wb_Hnd % handle to waitbar
		wrnOld % previous warnings
		fmtOTL % format string open-to-line
		inpArg = {}; % input arguments
		outExp = {}; % expected output arguments
		cntNow = 0; % count of current test
		cntTot = 0; % count of all tests
		cntFld = 0; % count of failed tests
		cntFlg = true; % count vs compare
	end
	methods
		function obj = test_nsx_fun(fnh) % constructor
			dbs = dbstack();
			fmt = '%s|%3d:';
			try %#ok<TRYNC> Octave
				if feature('hotlinks')
					fmt = '<a href="matlab:opentoline(''%1$s'',%2$d)">%1$s|%2$d:</a>';
				end
			end
			obj.funHnd = fnh;
			obj.fmtOTL = fmt;
			obj.wb_Hnd = waitbar(0,'Counting tests...', 'IntegerHandle','off', 'Name',dbs(2).name);
			drawnow()
		end
		function warn(obj,txt) % warning text
			if obj.cntFlg
				warning(txt)
			end
		end
		function out = o(obj,varargin) % expected outputs
			obj.outExp = varargin;
			if nargout
				out = obj;
			else
				obj.check();
			end
		end
		function out = i(obj,varargin) % input arguments
			obj.inpArg = varargin;
			if nargout
				out = obj;
			else
				obj.check();
			end
		end
		function start(obj) % start execution
			obj.cntFlg = false;
			obj.wrnOld = warning('off','SC:natsort:rgx:SanityCheck');
			waitbar(0,obj.wb_Hnd,'Starting tests...');
			drawnow()
		end
		function finish(obj) % finish execution
			dbs = dbstack();
			fprintf(obj.fmtOTL, dbs(2).file, dbs(2).line);
			fprintf(' %d of %d tests failed.\n', obj.cntFld, obj.cntTot)
			warning(obj.wrnOld);
			close(obj.wb_Hnd);
		end
		function check(obj) % compare expected against actual output
			if obj.cntFlg % count
				obj.cntTot = obj.cntTot + 1;
			else % execute & compare
				obj.cntNow = obj.cntNow + 1;
				waitbar(obj.cntNow/obj.cntTot, obj.wb_Hnd, sprintf('Running test %d of %d', obj.cntNow, obj.cntTot));
				drawnow()
				dbs = dbstack();
				inC = obj.inpArg;
				xpC = obj.outExp;
				opC =  cell(size(xpC));
				boo = false(size(xpC));
				[opC{:}] = obj.funHnd(inC{:});
				for k = 1:numel(xpC)
					opA = opC{k};
					xpA = xpC{k};
					if isequal(xpA,@i)
						% ignore this output
					elseif ~isequal(class(opA),class(xpA))
						boo(k) = true;
						opT = class(opA);
						xpT = class(xpA);
					elseif ~tnfIsEqNan(opA,xpA)
						boo(k) = true;
						if isa(xpA,'table')
							opV = opA.Properties.VariableNames;
							xpV = xpA.Properties.VariableNames;
							if isequal(opV,xpV)
								[~,opX] = ismember(opA,xpA,'rows');
								[~,xpX] = ismember(xpA,opA,'rows');
								opY = 1:size(opA,1);
								xpY = 1:size(xpA,1);
								opT = ['RowIndices:',tnfPretty(xpX),tnfPretty(opY(:))];
								xpT = ['RowIndices:',tnfPretty(xpY(:)),tnfPretty(opX)];
							else % different variables
								boo(k) = true;
								opT = ['VariableNames:',tnfPretty(opV)];
								xpT = ['VariableNames:',tnfPretty(xpV)];
							end
						else % string, cell of char, char, numeric, struct
							opT = tnfPretty(opA);
							xpT = tnfPretty(xpA);
						end
					end
					if boo(k)
						dmn = min(numel(opT),numel(xpT));
						dmx = max(numel(opT),numel(xpT));
						erT = repmat('^',1,dmx);
						erT(opT(1:dmn)==xpT(1:dmn)) = ' ';
						%
						fprintf(obj.fmtOTL, dbs(3).file, dbs(3).line);
						fprintf(' (output #%d)\n',k);
						fprintf('actual: %s\n', opT);
						fprintf('expect: %s\n', xpT);
						fprintf('  diff: ')
						fprintf(2,'%s\n',erT); % red!
					end
				end
				obj.cntFld = obj.cntFld + any(boo);
				obj.inpArg = {};
			end
		end
	end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%test_nsx_fun
function out = tnfIsEqNan(varargin)
try
	out = isequalwithequalnans(varargin{:}); %#ok<DISEQN>
catch
	out = isequaln(varargin{:});
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%tnfIsEqNan
function out = tnfPretty(inp)
if isempty(inp)|| ndims(inp)>2 %#ok<ISMAT>
	out = sprintf('x%u',size(inp));
	out = sprintf('%s %s',out(2:end),class(inp));
elseif isnumeric(inp) || islogical(inp)
	out = regexprep(mat2str(inp,23),'\s+',',');
elseif ischar(inp)
	if size(inp,1)>1
		out = mat2str(inp,15);
	else
		out = sprintf('''%s''',inp);
	end
elseif isa(inp,'string')
	if isscalar(inp)
		out = sprintf('"%s"',inp);
	else
		fmt = repmat(',"%s"',1,size(inp,2));
		out = sprintf([';',fmt(2:end)],inp.');
		out = sprintf('[%s]',out(2:end));
	end
elseif iscell(inp)
	tmp = cellfun(@tnfPretty,inp.','uni',0);
	fmt = repmat(',%s',1,size(inp,2));
	out = sprintf([';',fmt(2:end)],tmp{:});
	out = sprintf('{%s}',out(2:end));
else
	error('Class "%s" is not supported.',class(inp))
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%tnfPretty