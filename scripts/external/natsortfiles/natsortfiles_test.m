function natsortfiles_test()
% Test function for NATSORTFILES.
%
% (c) 2014-2025 Stephen Cobeldick
%
%% Dependencies %%
%
% * MATLAB R2009b or later.
% * natsortfiles.m & test_nsx_fun.m from <www.mathworks.com/matlabcentral/fileexchange/47434>
%
% See also NATSORTFILES TEST_NSX_FUN ARBSORT_TEST NATSORT_TEST NATSORTROWS_TEST
obj = test_nsx_fun(@natsortfiles);
nsfMain(obj) % count
obj.start()
nsfMain(obj) % check
obj.finish()
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%natsortfiles_test
function nsfMain(chk)
%
c2s = @(c)struct('name',cellstr(c));
rmf = @(s)rmfield(s,setdiff(fieldnames(s),'name'));
%
try pad(strings()); iss=true; catch; iss=false; chk.warn('No string class.'); end %#ok<CTCH,WNTAG>
%
if iss
	txf = @string;
else
	txf = @cellstr;
end
%
%% Mfile Examples %%
%
Aa =        {'a2.txt','a10.txt','a1.txt'};
chk.i(Aa).o({'a1.txt','a2.txt','a10.txt'})
chk.i(Aa).o({'a1.txt','a2.txt','a10.txt'}, [3,1,2]) % not in Mfile
chk.i(Aa).o(@i, [3,1,2], {{'a',2;'a',10;'a',1},{'.txt';'.txt';'.txt'}}) % not in Mfile
%
Ab =        {'test2.m';'test10-old.m';'test.m';'test10.m';'test1.m'};
chk.i(Ab).o({'test.m';'test1.m';'test2.m';'test10.m';'test10-old.m'})
chk.i(Ab).o({'test.m';'test1.m';'test2.m';'test10.m';'test10-old.m'}, [3;5;1;4;2]) % not in Mfile
chk.i(Ab).o(@i, [3;5;1;4;2], {{'test',2,[];'test',10,'-old';'test',[],[];'test',10,[];'test',1,[]},{'.m';'.m';'.m';'.m';'.m'}}) % not in Mfile
%
Ac =        {'A2-old\test.m';'A10\test.m';'A2\test.m';'A1\test.m';'A1-archive.zip'};
chk.i(Ac).o({'A1\test.m';'A1-archive.zip';'A2\test.m';'A2-old\test.m';'A10\test.m'})
chk.i(Ac).o({'A1\test.m';'A1-archive.zip';'A2\test.m';'A2-old\test.m';'A10\test.m'}, [4;5;3;1;2]) % not in Mfile
chk.i(Ac).o(@i, [4;5;3;1;2], {{'A',2,'-old';'A',10,[];'A',2,[];'A',1,[];'A',1,'-archive'},{'test';'test';'test';'test';[]},{'.m';'.m';'.m';'.m';'.zip'}}) % not in Mfile
%
Ad =        {'A1\B','A+/B','A/B1','A=/B','A\B0'};
chk.i(Ad).o({'A\B0','A/B1','A1\B','A+/B','A=/B'})
chk.i(Ad).o({'A\B0','A/B1','A1\B','A+/B','A=/B'}, [5,3,1,2,4]) % not in Mfile
chk.i(Ad).o(@i, [5,3,1,2,4], {{'A',1;'A+',[];'A',[];'A=',[];'A',[]},{'B',[];'B',[];'B',1;'B',[];'B',0},cell(5,0)}) % not in Mfile
%
Af =        {'test_new.m';'test-old.m';'test.m'};
chk.i(Af).o({'test.m';'test-old.m';'test_new.m'})
chk.i(Af).o({'test.m';'test-old.m';'test_new.m'}, [3;2;1]) % not in Mfile
chk.i(Af).o(@i, [3;2;1], {{'test_new';'test-old';'test'},{'.m';'.m';'.m'}}) % not in Mfile
%
%% HTML Examples %%
%
Aa =        txf({'a2.txt','a10.txt','a1.txt'});
chk.i(Aa).o(txf({'a1.txt','a2.txt','a10.txt'}))
chk.i(Aa).o(@i, [3,1,2]) % Not in HTML
chk.i(Aa).o(@i, [3,1,2], {{'a',2;'a',10;'a',1},{'.txt';'.txt';'.txt'}}) % not in HTML
chk.i(Aa).o(@i,      @i, {{'a',2;'a',10;'a',1},{'.txt';'.txt';'.txt'}}) % not in HTML
%
[P,Q] = nsfMakeFiles();
S = dir(fullfile('.',P,'A*.txt'));
chk.i(rmf(S)).o(c2s(Q))
%
Ab =                     txf({'1.3.txt','1.10.txt','1.2.txt'});
chk.i(Ab             ).o(txf({'1.2.txt','1.3.txt','1.10.txt'}))
chk.i(Ab             ).o(txf({'1.2.txt','1.3.txt','1.10.txt'}), [3,1,2]) % not in HTML
chk.i(Ab, '\d+\.?\d*').o(txf({'1.10.txt','1.2.txt','1.3.txt'}))
chk.i(Ab, '\d+\.?\d*').o(txf({'1.10.txt','1.2.txt','1.3.txt'}), [2,3,1]) % not in HTML
chk.i(Ab             ).o(@i, [3,1,2], {{1,'.',3;1,'.',10;1,'.',2},{'.txt';'.txt';'.txt'}}) % not in HTML
chk.i(Ab, '\d+\.?\d*').o(@i, [2,3,1], {{1.3;1.1;1.2},{'.txt';'.txt';'.txt'}}) % not in HTML
%
chk.i(...
	{'natsort_doc.html','natsortrows_doc.html','..','.'}, [], 'rmdot').o(...
	{'natsort_doc.html','natsortrows_doc.html'})
%
Ac =                              txf({'1.9','1.10','1.2'});
chk.i(Ac, '\d+\.?\d*'         ).o(txf({'1.2','1.9','1.10'}))
chk.i(Ac, '\d+\.?\d*'         ).o(txf({'1.2','1.9','1.10'}), [3,1,2]) % not in HTML
chk.i(Ac, '\d+\.?\d*', 'noext').o(txf({'1.10','1.2','1.9'}))
chk.i(Ac, '\d+\.?\d*', 'noext').o(txf({'1.10','1.2','1.9'}), [2,3,1]) % not in HTML
chk.i(Ac, '\d+\.?\d*'         ).o(@i, [3,1,2], {{1;1;1},{'.',9;'.',10;'.',2}}) % not in HTML
chk.i(Ac, '\d+\.?\d*', 'noext').o(@i, [2,3,1], {{1.9;1.1;1.2}}) % not in HTML
%
Ad =                     txf({'B/3.txt','A/1.txt','B/100.txt','A/20.txt'});
chk.i(Ad             ).o(txf({'A/1.txt','A/20.txt','B/3.txt','B/100.txt'}))
chk.i(Ad             ).o(txf({'A/1.txt','A/20.txt','B/3.txt','B/100.txt'}), [2,4,1,3]) % not in HTML
chk.i(Ad, [], 'xpath').o(txf({'A/1.txt','B/3.txt','A/20.txt','B/100.txt'}))
chk.i(Ad, [], 'xpath').o(txf({'A/1.txt','B/3.txt','A/20.txt','B/100.txt'}), [2,1,4,3]) % not in HTML
chk.i(Ad             ).o(@i, [2,4,1,3], {{'B';'A';'B';'A'},{3;1;100;20},{'.txt';'.txt';'.txt';'.txt'}}) % not in HTML
chk.i(Ad, [], 'xpath').o(@i, [2,1,4,3], {{3;1;100;20},{'.txt';'.txt';'.txt';'.txt'}}) % not in HTML
%
Ae =                        txf({'B.txt','10.txt','1.txt','A.txt','2.txt'});
chk.i(Ae, [],  'descend').o(txf({'B.txt','A.txt','10.txt','2.txt','1.txt'}))
chk.i(Ae, [], 'char<num').o(txf({'A.txt','B.txt','1.txt','2.txt','10.txt'}))
chk.i(Ae, []).o(@i, @i, {{'B';10;1;'A';2},{'.txt';'.txt';'.txt';'.txt';'.txt'}}) % not in HTML
%
Bf = {{'abc',2,'xyz';'abc',10,'xyz';'abc',2,'xyz';'abc',1,'xyz'},{'.txt';'.txt';'.txt';'.txt'}};
Af =        txf({'abc2xyz.txt','abc10xyz.txt','abc2xyz.txt','abc1xyz.txt'});
chk.i(Af).o(txf({'abc1xyz.txt','abc2xyz.txt','abc2xyz.txt','abc10xyz.txt'}))
chk.i(Af).o(txf({'abc1xyz.txt','abc2xyz.txt','abc2xyz.txt','abc10xyz.txt'}), [4,1,3,2])  % not in HTML
chk.i(Af).o(txf({'abc1xyz.txt','abc2xyz.txt','abc2xyz.txt','abc10xyz.txt'}), [4,1,3,2], Bf) % not in HTML
chk.i(Af).o(@i, @i, Bf)
%
chk.i(... Ag
	{'test_ccc.m';'test-aaa.m';'test.m';'test.bbb.m'}).o(...
	{'test.m';'test-aaa.m';'test.bbb.m';'test_ccc.m'}, [3;2;4;1]) % index not in HTML
chk.i(... Ah
	{'test2.m';'test10-old.m';'test.m';'test10.m';'test1.m'}).o(...
	{'test.m';'test1.m';'test2.m';'test10.m';'test10-old.m'}, [3;5;1;4;2]) % index not in HTML
chk.i(... Ai
	{'A2-old\test.m';'A10\test.m';'A2\test.m';'AXarchive.zip';'A1\test.m'}).o(...
	{'A1\test.m';'A2\test.m';'A2-old\test.m';'A10\test.m';'AXarchive.zip'}, [5;3;1;2;4]) % index not in HTML
%
Aj =                          txf({'1.23V.csv','-1V.csv','+1.csv','010V.csv','1.200V.csv'});
chk.i(Aj                  ).o(txf({'1.23V.csv','1.200V.csv','010V.csv','+1.csv','-1V.csv'}))
chk.i(Aj                  ).o(txf({'1.23V.csv','1.200V.csv','010V.csv','+1.csv','-1V.csv'}), [1,5,4,3,2]) % not in HTML
chk.i(Aj, '[+-]?\d+\.?\d*').o(txf({'-1V.csv','+1.csv','1.200V.csv','1.23V.csv','010V.csv'}))
chk.i(Aj, '[+-]?\d+\.?\d*').o(txf({'-1V.csv','+1.csv','1.200V.csv','1.23V.csv','010V.csv'}), [2,3,5,1,4]) % not in HTML
chk.i(Aj                  ).o(@i, [1,5,4,3,2], {{1,'.',23,'V';'-',1,'V',[];'+',1,[],[];10,'V',[],[];1,'.',200,'V'},{'.csv';'.csv';'.csv';'.csv';'.csv'}}) % not in HTML
chk.i(Aj, '[+-]?\d+\.?\d*').o(@i, [2,3,5,1,4], {{1.23,'V';-1,'V';1,[];10,'V';1.2,'V'},{'.csv';'.csv';'.csv';'.csv';'.csv'}}) % not in HTML
%
Ak =                    txf({'1,3.txt', '1,10.txt', '1,2.txt'});
chk.i(Ak, '\d+,?\d*').o(txf({'1,10.txt', '1,2.txt', '1,3.txt'}))
chk.i(Ak, '\d+,?\d*').o(@i, [2,3,1], {{1.3;1.1;1.2},{'.txt';'.txt';'.txt'}}) % not in HTML
%
%% Numeric XOR Alphabetic %%

K =                        {'100','00','20','1','0','2'}; L = {num2cell(str2double(K(:))),cell(6,0)};
chk.i(K                ).o({'00','0','1','2','20','100'}, [2,5,4,6,3,1], L)
chk.i(K, [], 'num<char').o({'00','0','1','2','20','100'}, [2,5,4,6,3,1], L)
chk.i(K, [], 'char<num').o({'00','0','1','2','20','100'}, [2,5,4,6,3,1], L)
chk.i(K, [],   'ascend').o({'00','0','1','2','20','100'}, [2,5,4,6,3,1], L)
chk.i(K, [],  'descend').o({'100','20','2','1','00','0'}, [1,3,6,4,2,5], L)

K =                        {'00','0','000','0','00','0'}; L = {num2cell(str2double(K(:))),cell(6,0)};
chk.i(K                ).o({'00','0','000','0','00','0'}, [1,2,3,4,5,6], L)
chk.i(K, [], 'num<char').o({'00','0','000','0','00','0'}, [1,2,3,4,5,6], L)
chk.i(K, [], 'char<num').o({'00','0','000','0','00','0'}, [1,2,3,4,5,6], L)
chk.i(K, [],   'ascend').o({'00','0','000','0','00','0'}, [1,2,3,4,5,6], L)
chk.i(K, [],  'descend').o({'00','0','000','0','00','0'}, [1,2,3,4,5,6], L)
%
K =                        {'BA','B','BAA','B','AA','A','CA','A','C'}; L = {K(:),cell(9,0)};
chk.i(K                ).o({'A','A','AA','B','B','BA','BAA','C','CA'}, [6,8,5,2,4,1,3,9,7], L)
chk.i(K, [], 'num<char').o({'A','A','AA','B','B','BA','BAA','C','CA'}, [6,8,5,2,4,1,3,9,7], L)
chk.i(K, [], 'char<num').o({'A','A','AA','B','B','BA','BAA','C','CA'}, [6,8,5,2,4,1,3,9,7], L)
chk.i(K, [],   'ascend').o({'A','A','AA','B','B','BA','BAA','C','CA'}, [6,8,5,2,4,1,3,9,7], L)
chk.i(K, [],  'descend').o({'CA','C','BAA','BA','B','B','AA','A','A'}, [7,9,3,1,2,4,5,6,8], L)
%
%% DIR Structure %%
%
S = dir(fullfile('.',P,'A*.xyz')); % zero files
chk.i(rmf(S)).o(c2s(cell(0,1)))
chk.i(reshape(rmf(S),0,0,2)).o(c2s(cell(0,0,2)))
chk.i(reshape(rmf(S),1,0,2)).o(c2s(cell(1,0,2)))
chk.i(reshape(rmf(S),2,0,2)).o(c2s(cell(2,0,2)))
chk.i(reshape(rmf(S),3,0,2)).o(c2s(cell(3,0,2)))
chk.i(reshape(rmf(S),4,0,2)).o(c2s(cell(4,0,2)))
chk.i(reshape(rmf(S),5,0,2)).o(c2s(cell(5,0,2)))
chk.i(reshape(rmf(S),6,0,2)).o(c2s(cell(6,0,2)))
chk.i(reshape(rmf(S),7,0,2)).o(c2s(cell(7,0,2)))
chk.i(reshape(rmf(S),8,0,2)).o(c2s(cell(8,0,2)))
chk.i(reshape(rmf(S),9,0,2)).o(c2s(cell(9,0,2)))
chk.i(reshape(rmf(S),0,0,2), [],  'ascend').o(c2s(cell(0,0,2)))
chk.i(reshape(rmf(S),1,0,2), [],  'ascend').o(c2s(cell(1,0,2)))
chk.i(reshape(rmf(S),2,0,2), [],  'ascend').o(c2s(cell(2,0,2)))
chk.i(reshape(rmf(S),3,0,2), [],  'ascend').o(c2s(cell(3,0,2)))
chk.i(reshape(rmf(S),4,0,2), [],  'ascend').o(c2s(cell(4,0,2)))
chk.i(reshape(rmf(S),5,0,2), [],  'ascend').o(c2s(cell(5,0,2)))
chk.i(reshape(rmf(S),0,0,2), [], 'descend').o(c2s(cell(0,0,2)))
chk.i(reshape(rmf(S),1,0,2), [], 'descend').o(c2s(cell(1,0,2)))
chk.i(reshape(rmf(S),2,0,2), [], 'descend').o(c2s(cell(2,0,2)))
chk.i(reshape(rmf(S),3,0,2), [], 'descend').o(c2s(cell(3,0,2)))
chk.i(reshape(rmf(S),4,0,2), [], 'descend').o(c2s(cell(4,0,2)))
chk.i(reshape(rmf(S),5,0,2), [], 'descend').o(c2s(cell(5,0,2)))
%
S = dir(fullfile('.',P,'A*3*.txt')); % one file
chk.i(rmf(S)).o(c2s({'A_3.txt'}))
chk.i(rmf(S), [],  'ascend').o(c2s({'A_3.txt'}))
chk.i(rmf(S), [], 'descend').o(c2s({'A_3.txt'}))
chk.i(rmf(S), [], 'rmdot',  'ascend').o(c2s({'A_3.txt'}))
chk.i(rmf(S), [], 'rmdot', 'descend').o(c2s({'A_3.txt'}))
%
S = dir(fullfile('.',P,'A*new.txt')); % two files
chk.i(rmf(S)).o(c2s({'A_1-new.txt';'A_1_new.txt'}))
chk.i(rmf(S), [],  'ascend').o(c2s({'A_1-new.txt';'A_1_new.txt'}))
chk.i(rmf(S), [], 'descend').o(c2s({'A_1_new.txt';'A_1-new.txt'}))
%
S = dir(fullfile('.',P,'A*0.txt')); % three files
chk.i(rmf(S)).o(c2s({'A_10.txt';'A_100.txt';'A_200.txt'}))
chk.i(rmf(S), [],  'ascend').o(c2s({'A_10.txt';'A_100.txt';'A_200.txt'}))
chk.i(rmf(S), [], 'descend').o(c2s({'A_200.txt';'A_100.txt';'A_10.txt'}))
%
S = dir(fullfile('.',P,'A*.txt')); % eight files
chk.i(reshape(rmf(S),1,8).').o(reshape(c2s(Q),8,1))
chk.i(reshape(rmf(S),2,4).').o(reshape(c2s(Q),4,2))
chk.i(reshape(rmf(S),4,2).').o(reshape(c2s(Q),2,4))
chk.i(reshape(rmf(S),8,1).').o(reshape(c2s(Q),1,8))
chk.i(reshape(rmf(S),1,8).', [],  'ascend').o(reshape(c2s(Q),8,1))
chk.i(reshape(rmf(S),2,4).', [],  'ascend').o(reshape(c2s(Q),4,2))
chk.i(reshape(rmf(S),4,2).', [],  'ascend').o(reshape(c2s(Q),2,4))
chk.i(reshape(rmf(S),8,1).', [],  'ascend').o(reshape(c2s(Q),1,8))
chk.i(reshape(rmf(S),1,8).', [], 'descend').o(reshape(c2s(Q(end:-1:1)),8,1))
chk.i(reshape(rmf(S),2,4).', [], 'descend').o(reshape(c2s(Q(end:-1:1)),4,2))
chk.i(reshape(rmf(S),4,2).', [], 'descend').o(reshape(c2s(Q(end:-1:1)),2,4))
chk.i(reshape(rmf(S),8,1).', [], 'descend').o(reshape(c2s(Q(end:-1:1)),1,8))
%
%% Dot Folder Names %%
%
S = dir(fullfile('.',P,'*'));
chk.i(rmf(S)                        ).o(c2s([{'.';'..'};Q]))
chk.i(rmf(S), [], 'rmdot'           ).o(c2s(Q))
chk.i(rmf(S), [], 'rmdot',  'ascend').o(c2s(Q))
chk.i(rmf(S), [],  'ascend', 'rmdot').o(c2s(Q))
chk.i(rmf(S), [], 'rmdot', 'descend').o(c2s(Q(end:-1:1)))
chk.i(rmf(S), [], 'descend', 'rmdot').o(c2s(Q(end:-1:1)))
%
T =                        {'...txt','txt.txt','','.','..txt','..','.','_.txt'};
chk.i(T                ).o({'','.','.','..','..txt','...txt','_.txt','txt.txt'},[3,4,7,6,5,1,8,2])
chk.i(T,    [], 'rmdot').o({'','..txt','...txt','_.txt','txt.txt'},[3,5,1,8,2])
chk.i(T(:)             ).o({'';'.';'.';'..';'..txt';'...txt';'_.txt';'txt.txt'},[3;4;7;6;5;1;8;2])
chk.i(T(:), [], 'rmdot').o({'';'..txt';'...txt';'_.txt';'txt.txt'},[3;5;1;8;2])
%
%% Orientation %%
%
chk.i({}).o({}, []) % empty!
chk.i({}, [],  'ascend').o({}, []) % empty!
chk.i({}, [], 'descend').o({}, []) % empty!
chk.i(cell(0,2,0)).o(cell(0,2,0), nan(0,2,0)) % empty!
chk.i(cell(0,2,1)).o(cell(0,2,1), nan(0,2,1)) % empty!
chk.i(cell(0,2,2)).o(cell(0,2,2), nan(0,2,2)) % empty!
chk.i(cell(0,2,3)).o(cell(0,2,3), nan(0,2,3)) % empty!
chk.i(cell(0,2,4)).o(cell(0,2,4), nan(0,2,4)) % empty!
chk.i(cell(0,2,5)).o(cell(0,2,5), nan(0,2,5)) % empty!
chk.i(cell(0,2,6)).o(cell(0,2,6), nan(0,2,6)) % empty!
chk.i(cell(0,2,7)).o(cell(0,2,7), nan(0,2,7)) % empty!
chk.i(cell(0,2,8)).o(cell(0,2,8), nan(0,2,8)) % empty!
chk.i(cell(0,2,9)).o(cell(0,2,9), nan(0,2,9)) % empty!
chk.i(cell(0,2,0), [],  'ascend').o(cell(0,2,0), nan(0,2,0)) % empty!
chk.i(cell(0,2,1), [],  'ascend').o(cell(0,2,1), nan(0,2,1)) % empty!
chk.i(cell(0,2,2), [],  'ascend').o(cell(0,2,2), nan(0,2,2)) % empty!
chk.i(cell(0,2,3), [],  'ascend').o(cell(0,2,3), nan(0,2,3)) % empty!
chk.i(cell(0,2,4), [],  'ascend').o(cell(0,2,4), nan(0,2,4)) % empty!
chk.i(cell(0,2,5), [],  'ascend').o(cell(0,2,5), nan(0,2,5)) % empty!
chk.i(cell(0,2,6), [],  'ascend').o(cell(0,2,6), nan(0,2,6)) % empty!
chk.i(cell(0,2,7), [],  'ascend').o(cell(0,2,7), nan(0,2,7)) % empty!
chk.i(cell(0,2,8), [],  'ascend').o(cell(0,2,8), nan(0,2,8)) % empty!
chk.i(cell(0,2,9), [],  'ascend').o(cell(0,2,9), nan(0,2,9)) % empty!
chk.i(cell(0,2,0), [], 'descend').o(cell(0,2,0), nan(0,2,0)) % empty!
chk.i(cell(0,2,1), [], 'descend').o(cell(0,2,1), nan(0,2,1)) % empty!
chk.i(cell(0,2,2), [], 'descend').o(cell(0,2,2), nan(0,2,2)) % empty!
chk.i(cell(0,2,3), [], 'descend').o(cell(0,2,3), nan(0,2,3)) % empty!
chk.i(cell(0,2,4), [], 'descend').o(cell(0,2,4), nan(0,2,4)) % empty!
chk.i(cell(0,2,5), [], 'descend').o(cell(0,2,5), nan(0,2,5)) % empty!
chk.i(cell(0,2,6), [], 'descend').o(cell(0,2,6), nan(0,2,6)) % empty!
chk.i(cell(0,2,7), [], 'descend').o(cell(0,2,7), nan(0,2,7)) % empty!
chk.i(cell(0,2,8), [], 'descend').o(cell(0,2,8), nan(0,2,8)) % empty!
chk.i(cell(0,2,9), [], 'descend').o(cell(0,2,9), nan(0,2,9)) % empty!
%
chk.i(...
	{'1';'10';'20';'2'}).o(...
	{'1';'2';'10';'20'}, [1;4;2;3], {{1;10;20;2},cell(4,0)})
chk.i(...
	{'2','10','8';'#','a',' '}).o(...
	{'2','10','#';'8',' ','a'}, [1,3,2;5,6,4], {{2;'#';10;'a';8;' '},cell(6,0)})
%
%% Index Stability %%
%
rmf = @(s,r,c)repmat({s},r,c);
chk.i(rmf('',1,0)).o(rmf('',1,0), 1:0,  cell(1,0))
chk.i(rmf('',1,1)).o(rmf('',1,1), 1:1, {cell(1,0),cell(1,0)})
chk.i(rmf('',1,2)).o(rmf('',1,2), 1:2, {cell(2,0),cell(2,0)})
chk.i(rmf('',1,3)).o(rmf('',1,3), 1:3, {cell(3,0),cell(3,0)})
chk.i(rmf('',1,4)).o(rmf('',1,4), 1:4, {cell(4,0),cell(4,0)})
chk.i(rmf('',1,5)).o(rmf('',1,5), 1:5, {cell(5,0),cell(5,0)})
chk.i(rmf('',1,6)).o(rmf('',1,6), 1:6, {cell(6,0),cell(6,0)})
chk.i(rmf('',1,7)).o(rmf('',1,7), 1:7, {cell(7,0),cell(7,0)})
chk.i(rmf('',1,8)).o(rmf('',1,8), 1:8, {cell(8,0),cell(8,0)})
chk.i(rmf('',1,9)).o(rmf('',1,9), 1:9, {cell(9,0),cell(9,0)})
chk.i(rmf('',1,0), [],  'ascend').o(rmf('',1,0), 1:0,  cell(1,0))
chk.i(rmf('',1,1), [],  'ascend').o(rmf('',1,1), 1:1, {cell(1,0),cell(1,0)})
chk.i(rmf('',1,2), [],  'ascend').o(rmf('',1,2), 1:2, {cell(2,0),cell(2,0)})
chk.i(rmf('',1,3), [],  'ascend').o(rmf('',1,3), 1:3, {cell(3,0),cell(3,0)})
chk.i(rmf('',1,4), [],  'ascend').o(rmf('',1,4), 1:4, {cell(4,0),cell(4,0)})
chk.i(rmf('',1,5), [],  'ascend').o(rmf('',1,5), 1:5, {cell(5,0),cell(5,0)})
chk.i(rmf('',1,6), [],  'ascend').o(rmf('',1,6), 1:6, {cell(6,0),cell(6,0)})
chk.i(rmf('',1,7), [],  'ascend').o(rmf('',1,7), 1:7, {cell(7,0),cell(7,0)})
chk.i(rmf('',1,8), [],  'ascend').o(rmf('',1,8), 1:8, {cell(8,0),cell(8,0)})
chk.i(rmf('',1,9), [],  'ascend').o(rmf('',1,9), 1:9, {cell(9,0),cell(9,0)})
chk.i(rmf('',1,0), [], 'descend').o(rmf('',1,0), 1:0,  cell(1,0))
chk.i(rmf('',1,1), [], 'descend').o(rmf('',1,1), 1:1, {cell(1,0),cell(1,0)})
chk.i(rmf('',1,2), [], 'descend').o(rmf('',1,2), 1:2, {cell(2,0),cell(2,0)})
chk.i(rmf('',1,3), [], 'descend').o(rmf('',1,3), 1:3, {cell(3,0),cell(3,0)})
chk.i(rmf('',1,4), [], 'descend').o(rmf('',1,4), 1:4, {cell(4,0),cell(4,0)})
chk.i(rmf('',1,5), [], 'descend').o(rmf('',1,5), 1:5, {cell(5,0),cell(5,0)})
chk.i(rmf('',1,6), [], 'descend').o(rmf('',1,6), 1:6, {cell(6,0),cell(6,0)})
chk.i(rmf('',1,7), [], 'descend').o(rmf('',1,7), 1:7, {cell(7,0),cell(7,0)})
chk.i(rmf('',1,8), [], 'descend').o(rmf('',1,8), 1:8, {cell(8,0),cell(8,0)})
chk.i(rmf('',1,9), [], 'descend').o(rmf('',1,9), 1:9, {cell(9,0),cell(9,0)})
chk.i(rmf('X.Y',1,0)).o(rmf('X.Y',1,0), 1:0, cell(1,0))
chk.i(rmf('X.Y',1,1)).o(rmf('X.Y',1,1), 1:1, {rmf('X',1,1),rmf('.Y',1,1)})
chk.i(rmf('X.Y',1,2)).o(rmf('X.Y',1,2), 1:2, {rmf('X',2,1),rmf('.Y',2,1)})
chk.i(rmf('X.Y',1,3)).o(rmf('X.Y',1,3), 1:3, {rmf('X',3,1),rmf('.Y',3,1)})
chk.i(rmf('X.Y',1,4)).o(rmf('X.Y',1,4), 1:4, {rmf('X',4,1),rmf('.Y',4,1)})
chk.i(rmf('X.Y',1,5)).o(rmf('X.Y',1,5), 1:5, {rmf('X',5,1),rmf('.Y',5,1)})
chk.i(rmf('X.Y',1,6)).o(rmf('X.Y',1,6), 1:6, {rmf('X',6,1),rmf('.Y',6,1)})
chk.i(rmf('X.Y',1,7)).o(rmf('X.Y',1,7), 1:7, {rmf('X',7,1),rmf('.Y',7,1)})
chk.i(rmf('X.Y',1,8)).o(rmf('X.Y',1,8), 1:8, {rmf('X',8,1),rmf('.Y',8,1)})
chk.i(rmf('X.Y',1,9)).o(rmf('X.Y',1,9), 1:9, {rmf('X',9,1),rmf('.Y',9,1)})
chk.i(rmf('X.Y',1,0), [],  'ascend').o(rmf('X.Y',1,0), 1:0, cell(1,0))
chk.i(rmf('X.Y',1,1), [],  'ascend').o(rmf('X.Y',1,1), 1:1, {rmf('X',1,1),rmf('.Y',1,1)})
chk.i(rmf('X.Y',1,2), [],  'ascend').o(rmf('X.Y',1,2), 1:2, {rmf('X',2,1),rmf('.Y',2,1)})
chk.i(rmf('X.Y',1,3), [],  'ascend').o(rmf('X.Y',1,3), 1:3, {rmf('X',3,1),rmf('.Y',3,1)})
chk.i(rmf('X.Y',1,4), [],  'ascend').o(rmf('X.Y',1,4), 1:4, {rmf('X',4,1),rmf('.Y',4,1)})
chk.i(rmf('X.Y',1,5), [],  'ascend').o(rmf('X.Y',1,5), 1:5, {rmf('X',5,1),rmf('.Y',5,1)})
chk.i(rmf('X.Y',1,6), [],  'ascend').o(rmf('X.Y',1,6), 1:6, {rmf('X',6,1),rmf('.Y',6,1)})
chk.i(rmf('X.Y',1,7), [],  'ascend').o(rmf('X.Y',1,7), 1:7, {rmf('X',7,1),rmf('.Y',7,1)})
chk.i(rmf('X.Y',1,8), [],  'ascend').o(rmf('X.Y',1,8), 1:8, {rmf('X',8,1),rmf('.Y',8,1)})
chk.i(rmf('X.Y',1,9), [],  'ascend').o(rmf('X.Y',1,9), 1:9, {rmf('X',9,1),rmf('.Y',9,1)})
chk.i(rmf('X.Y',1,0), [], 'descend').o(rmf('X.Y',1,0), 1:0, cell(1,0))
chk.i(rmf('X.Y',1,1), [], 'descend').o(rmf('X.Y',1,1), 1:1, {rmf('X',1,1),rmf('.Y',1,1)})
chk.i(rmf('X.Y',1,2), [], 'descend').o(rmf('X.Y',1,2), 1:2, {rmf('X',2,1),rmf('.Y',2,1)})
chk.i(rmf('X.Y',1,3), [], 'descend').o(rmf('X.Y',1,3), 1:3, {rmf('X',3,1),rmf('.Y',3,1)})
chk.i(rmf('X.Y',1,4), [], 'descend').o(rmf('X.Y',1,4), 1:4, {rmf('X',4,1),rmf('.Y',4,1)})
chk.i(rmf('X.Y',1,5), [], 'descend').o(rmf('X.Y',1,5), 1:5, {rmf('X',5,1),rmf('.Y',5,1)})
chk.i(rmf('X.Y',1,6), [], 'descend').o(rmf('X.Y',1,6), 1:6, {rmf('X',6,1),rmf('.Y',6,1)})
chk.i(rmf('X.Y',1,7), [], 'descend').o(rmf('X.Y',1,7), 1:7, {rmf('X',7,1),rmf('.Y',7,1)})
chk.i(rmf('X.Y',1,8), [], 'descend').o(rmf('X.Y',1,8), 1:8, {rmf('X',8,1),rmf('.Y',8,1)})
chk.i(rmf('X.Y',1,9), [], 'descend').o(rmf('X.Y',1,9), 1:9, {rmf('X',9,1),rmf('.Y',9,1)})
chk.i(rmf('9.Y',1,0)).o(rmf('9.Y',1,0), 1:0, cell(1,0))
chk.i(rmf('9.Y',1,1)).o(rmf('9.Y',1,1), 1:1, {rmf(9,1,1),rmf('.Y',1,1)})
chk.i(rmf('9.Y',1,2)).o(rmf('9.Y',1,2), 1:2, {rmf(9,2,1),rmf('.Y',2,1)})
chk.i(rmf('9.Y',1,3)).o(rmf('9.Y',1,3), 1:3, {rmf(9,3,1),rmf('.Y',3,1)})
chk.i(rmf('9.Y',1,4)).o(rmf('9.Y',1,4), 1:4, {rmf(9,4,1),rmf('.Y',4,1)})
chk.i(rmf('9.Y',1,5)).o(rmf('9.Y',1,5), 1:5, {rmf(9,5,1),rmf('.Y',5,1)})
chk.i(rmf('9.Y',1,6)).o(rmf('9.Y',1,6), 1:6, {rmf(9,6,1),rmf('.Y',6,1)})
chk.i(rmf('9.Y',1,7)).o(rmf('9.Y',1,7), 1:7, {rmf(9,7,1),rmf('.Y',7,1)})
chk.i(rmf('9.Y',1,8)).o(rmf('9.Y',1,8), 1:8, {rmf(9,8,1),rmf('.Y',8,1)})
chk.i(rmf('9.Y',1,9)).o(rmf('9.Y',1,9), 1:9, {rmf(9,9,1),rmf('.Y',9,1)})
chk.i(rmf('9.Y',1,0), [],  'ascend').o(rmf('9.Y',1,0), 1:0, cell(1,0))
chk.i(rmf('9.Y',1,1), [],  'ascend').o(rmf('9.Y',1,1), 1:1, {rmf(9,1,1),rmf('.Y',1,1)})
chk.i(rmf('9.Y',1,2), [],  'ascend').o(rmf('9.Y',1,2), 1:2, {rmf(9,2,1),rmf('.Y',2,1)})
chk.i(rmf('9.Y',1,3), [],  'ascend').o(rmf('9.Y',1,3), 1:3, {rmf(9,3,1),rmf('.Y',3,1)})
chk.i(rmf('9.Y',1,4), [],  'ascend').o(rmf('9.Y',1,4), 1:4, {rmf(9,4,1),rmf('.Y',4,1)})
chk.i(rmf('9.Y',1,5), [],  'ascend').o(rmf('9.Y',1,5), 1:5, {rmf(9,5,1),rmf('.Y',5,1)})
chk.i(rmf('9.Y',1,6), [],  'ascend').o(rmf('9.Y',1,6), 1:6, {rmf(9,6,1),rmf('.Y',6,1)})
chk.i(rmf('9.Y',1,7), [],  'ascend').o(rmf('9.Y',1,7), 1:7, {rmf(9,7,1),rmf('.Y',7,1)})
chk.i(rmf('9.Y',1,8), [],  'ascend').o(rmf('9.Y',1,8), 1:8, {rmf(9,8,1),rmf('.Y',8,1)})
chk.i(rmf('9.Y',1,9), [],  'ascend').o(rmf('9.Y',1,9), 1:9, {rmf(9,9,1),rmf('.Y',9,1)})
chk.i(rmf('9.Y',1,0), [], 'descend').o(rmf('9.Y',1,0), 1:0, cell(1,0))
chk.i(rmf('9.Y',1,1), [], 'descend').o(rmf('9.Y',1,1), 1:1, {rmf(9,1,1),rmf('.Y',1,1)})
chk.i(rmf('9.Y',1,2), [], 'descend').o(rmf('9.Y',1,2), 1:2, {rmf(9,2,1),rmf('.Y',2,1)})
chk.i(rmf('9.Y',1,3), [], 'descend').o(rmf('9.Y',1,3), 1:3, {rmf(9,3,1),rmf('.Y',3,1)})
chk.i(rmf('9.Y',1,4), [], 'descend').o(rmf('9.Y',1,4), 1:4, {rmf(9,4,1),rmf('.Y',4,1)})
chk.i(rmf('9.Y',1,5), [], 'descend').o(rmf('9.Y',1,5), 1:5, {rmf(9,5,1),rmf('.Y',5,1)})
chk.i(rmf('9.Y',1,6), [], 'descend').o(rmf('9.Y',1,6), 1:6, {rmf(9,6,1),rmf('.Y',6,1)})
chk.i(rmf('9.Y',1,7), [], 'descend').o(rmf('9.Y',1,7), 1:7, {rmf(9,7,1),rmf('.Y',7,1)})
chk.i(rmf('9.Y',1,8), [], 'descend').o(rmf('9.Y',1,8), 1:8, {rmf(9,8,1),rmf('.Y',8,1)})
chk.i(rmf('9.Y',1,9), [], 'descend').o(rmf('9.Y',1,9), 1:9, {rmf(9,9,1),rmf('.Y',9,1)})
%
V =                       {'x';'z';'y';'';'z';'';'x';'y'};
chk.i(V               ).o({'';'';'x';'x';'y';'y';'z';'z'},[4;6;1;7;3;8;2;5])
chk.i(V, [],  'ascend').o({'';'';'x';'x';'y';'y';'z';'z'},[4;6;1;7;3;8;2;5])
chk.i(V, [], 'descend').o({'z';'z';'y';'y';'x';'x';'';''},[2;5;3;8;1;7;4;6])
%
W =                       {'2x';'2z';'2y';'2';'2z';'2';'2x';'2y'};
chk.i(W               ).o({'2';'2';'2x';'2x';'2y';'2y';'2z';'2z'},[4;6;1;7;3;8;2;5])
chk.i(W, [],  'ascend').o({'2';'2';'2x';'2x';'2y';'2y';'2z';'2z'},[4;6;1;7;3;8;2;5])
chk.i(W, [], 'descend').o({'2z';'2z';'2y';'2y';'2x';'2x';'2';'2'},[2;5;3;8;1;7;4;6])
%
%% Extension and Separator Characters %%
%
chk.i(...
	{'A.x3','','A.x20','A.x','A','A.x1'}).o(...
	{'','A','A.x','A.x1','A.x3','A.x20'}, [2,5,4,6,1,3])
chk.i(...
	{'A=.z','A.z','A..z','A-.z','A#.z'}).o(...
	{'A.z','A#.z','A-.z','A..z','A=.z'}, [2,5,4,3,1])
chk.i(...
	{'A~/B','A/B','A#/B','A=/B','A-/B'}).o(...
	{'A/B','A#/B','A-/B','A=/B','A~/B'}, [2,3,5,4,1])
%
X =                              {'1.10','1.2'};
chk.i(X, '\d+\.?\d*'         ).o({'1.2','1.10'}, [2,1], {{1;1},{'.',10;'.',2}})
chk.i(X, '\d+\.?\d*', 'noext').o({'1.10','1.2'}, [1,2], {{1.1;1.2}})
%
Y =                                         {'1.2','2.2','20','2','2.10','10','1','2.00','1.10'};
chk.i(Y, '\d+\.?\d*'                    ).o({'1','1.2','1.10','2','2.00','2.2','2.10','10','20'},[7,1,9,4,8,2,5,6,3])
chk.i(Y, '\d+\.?\d*', 'noext'           ).o({'1','1.10','1.2','2','2.00','2.10','2.2','10','20'},[7,9,1,4,8,5,2,6,3])
chk.i(Y, '\d+\.?\d*', 'noext',  'ascend').o({'1','1.10','1.2','2','2.00','2.10','2.2','10','20'},[7,9,1,4,8,5,2,6,3])
chk.i(Y, '\d+\.?\d*', 'noext', 'descend').o({'20','10','2.2','2.10','2','2.00','1.2','1.10','1'},[3,6,2,5,4,8,1,9,7])
%
%% Other Implementation Examples %%
%
% <https://blog.codinghorror.com/sorting-for-humans-natural-sort-order/>
chk.i(...
	{'z1.txt','z10.txt','z100.txt','z101.txt','z102.txt','z11.txt','z12.txt','z13.txt','z14.txt','z15.txt','z16.txt','z17.txt','z18.txt','z19.txt','z2.txt','z20.txt','z3.txt','z4.txt','z5.txt','z6.txt','z7.txt','z8.txt','z9.txt'}).o(...
	{'z1.txt','z2.txt','z3.txt','z4.txt','z5.txt','z6.txt','z7.txt','z8.txt','z9.txt','z10.txt','z11.txt','z12.txt','z13.txt','z14.txt','z15.txt','z16.txt','z17.txt','z18.txt','z19.txt','z20.txt','z100.txt','z101.txt','z102.txt'})
%
% <https://blog.jooq.org/2018/02/23/how-to-order-file-names-semantically-in-java/>
chk.i(...
	{'C:\temp\version-1.sql','C:\temp\version-10.1.sql','C:\temp\version-10.sql','C:\temp\version-2.sql','C:\temp\version-21.sql'}).o(...
	{'C:\temp\version-1.sql','C:\temp\version-2.sql','C:\temp\version-10.sql','C:\temp\version-10.1.sql','C:\temp\version-21.sql'})
%
% <http://www.davekoelle.com/alphanum.html>
chk.i(...
	{'z1.doc','z10.doc','z100.doc','z101.doc','z102.doc','z11.doc','z12.doc','z13.doc','z14.doc','z15.doc','z16.doc','z17.doc','z18.doc','z19.doc','z2.doc','z20.doc','z3.doc','z4.doc','z5.doc','z6.doc','z7.doc','z8.doc','z9.doc'}).o(...
	{'z1.doc','z2.doc','z3.doc','z4.doc','z5.doc','z6.doc','z7.doc','z8.doc','z9.doc','z10.doc','z11.doc','z12.doc','z13.doc','z14.doc','z15.doc','z16.doc','z17.doc','z18.doc','z19.doc','z20.doc','z100.doc','z101.doc','z102.doc'})
%
% <https://sourcefrog.net/projects/natsort/>
chk.i(...
	{'rfc1.txt';'rfc2086.txt';'rfc822.txt'}).o(...
	{'rfc1.txt';'rfc822.txt';'rfc2086.txt'})
%
% <https://www.strchr.com/natural_sorting>
chk.i(...
	{'picture 1.png','picture 10.png','picture 100.png','picture 11.png','picture 2.png','picture 21.png','picture 2_10.png','picture 2_9.png','picture 3.png','picture 3b.png','picture A.png'}).o(...
	{'picture 1.png','picture 2.png','picture 2_9.png','picture 2_10.png','picture 3.png','picture 3b.png','picture 10.png','picture 11.png','picture 21.png','picture 100.png','picture A.png'})
%
% <https://github.com/sourcefrog/natsort>
chk.i(...
	{'rfc1.txt','rfc2086.txt','rfc822.txt'}).o(...
	{'rfc1.txt','rfc822.txt','rfc2086.txt'})
%
% <https://www.php.net/manual/en/function.natsort.php>
chk.i(...
	{'img12.png', 'img10.png', 'img2.png', 'img1.png'}).o(...
	{'img1.png', 'img2.png', 'img10.png', 'img12.png'})
%
% <http://www.naturalordersort.org/>
chk.i(...
	{'Picture1.jpg';'Picture10.jpg';'Picture11.jpg';'Picture12.jpg';'Picture2.jpg';'Picture3.jpg';'Picture4.jpg';'Picture5.jpg';'Picture6.jpg';'Picture7.jpg';'Picture8.jpg';'Picture9.jpg'}).o(...
	{'Picture1.jpg';'Picture2.jpg';'Picture3.jpg';'Picture4.jpg';'Picture5.jpg';'Picture6.jpg';'Picture7.jpg';'Picture8.jpg';'Picture9.jpg';'Picture10.jpg';'Picture11.jpg';'Picture12.jpg'})
%
%rmdir(P,'s')
%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%nsfMain
function [fnm,tmp] = nsfMakeFiles()
fnm = 'natsortfiles_test';
tmp = {'A_1.txt';'A_1-new.txt';'A_1_new.txt';'A_2.txt';'A_3.txt';'A_10.txt';'A_100.txt';'A_200.txt'};
delete(fullfile('.',fnm,'*.*'))
[status,msg] = mkdir(fullfile('.',fnm)); %#ok<ASGLU>
cellfun(@(f)dlmwrite(fullfile('.',fnm,f),0),tmp); %#ok<DLMWT>
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%nsfMakeFiles