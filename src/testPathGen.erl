-module(testPathGen).
-compile([export_all, nowarn_export_all]).

% testing path generation with QC and Z3

samplePath()->
	P1 = [{1,5}, { 0,5}, {0,4}, {0,3}, {1,3}, {1,2}, {1,1}],
	P2 = [{3,5}, { 3,6}, {4,6}, {5,6}, {5,5}, {5,4}, {6,4}],
	P3 = [{3,4}, { 4,4}, {4,3}, {4,2}, {4,1}, {5,1}, {5,0}],
	P4 = [{5,2}, { 4,2}, {3,2}, {3,1}, {2,1}, {2,2}, {1,2}],
	[P1]++[P2]++[P3]++[P4].

samplePath2()->
	P1 = [{7,5}, { 7,4}, {7,3}, {8,3}, {7,3}, {7,2}],
	P2 = [{5,5}, { 6,5}, {6,6}, {6,7}, {6,8}, {6,9}],
	P3 = [{4,0}, { 5,0}, {6,0}, {6,1}, {7,1}, {8,1}],
	P4 = [{4,8}, { 4,7}, {5,7}, {5,6}, {6,6}, {6,5}],
	P5 = [{5,9}, { 5,8}, {5,7}, {5,6}, {6,6}, {5,6}],
	[P1]++[P2]++[P3]++[P4]++[P5].

test()->
    GridX = 10,
    GridY = 10,
    AgentsNum = 4,
    WaitSteps = 0,
    DispSteps = 6,
    %InputNum = 5,
    TestInput = samplePath(),
    CSs = {"IN", {"Circle",2},{"Count", 4}},       % error handling is needded in python or erlang side on the size of the area/condition when they exceed number of agents,etc
    {ok, P} = python:start(), % calling python 3 (python 2 throws some errors)
    python:call(P, pathGenerator, register_handler, [self()]),
    python:cast(P,{GridX, GridY,AgentsNum, WaitSteps,DispSteps, CSs, "Filter", TestInput}),
    receive
        R->
            begin
                %[io:fwrite("Set of Paths:~n~w~n",[Inp]) || Inp<-R],
                if
                    (R==true) -> io:fwrite("Is Satisfied.~n");
                    (R==false)-> io:fwrite("Is Not Satisfied.~n")
                end,
                io:fwrite("Finished!"),
                ok
            end
    end.


testz3_SpecificCase()->
	GridSize  = 10,%lists:seq(15,15),
	AgentsNum = 3, %lists:seq(5,20),
	WaitSteps  = 0,
	DispSteps  = 5,%lists:seq(1,20),
%% 	InputNum  = 1,
	TimeOutSec = 60,  % time-out for one
	TurtlesPaths = [{1,1,0,[right,right,right]},
					{2,0,0,[right,right,right]},
					{3,0,0,[right,right,right]}],
	CS= {"NOT",{"IN", {"Square", 2}, {"Count", 3}}},
	{ok, P} = python:start(), 
	python:call(P, pathGenerator, register_handler, [self()]),
	python:cast(P,{GridSize, GridSize,AgentsNum, WaitSteps,DispSteps, CS, "Filter", turtle_nop:calculateAllPathsPoints(TurtlesPaths,GridSize, GridSize), TimeOutSec}),
	receive
        Ans->
			begin
%% 				io:format("~w~n", [Ans]),
				python:stop(P),
				io:format(Ans)
			end
	after TimeOutSec*1000 ->
		python:stop(P),
		exit(P, kill),
		"Time-out"
    end.


testQC_SpecificCase()->
	GridSize  = 10,%lists:seq(15,15),
	AgentsNum = 4, %lists:seq(5,20),
	WaitSteps  = 0,
	DispSteps  = 3,%lists:seq(1,20),
%% 	InputNum  = 1,
	TimeOutSec = 60,  % time-out for one
	TurtlesPaths = [
					{1,0,0,[up,right,right]},
					{2,0,0,[right,right,right]},
					{3,0,0,[right,right,up]}],
	CS= {"NOT",{"IN", {"Circle", 1}, {"Intersection", 1,3}}},
	{ok, P} = python:start(), 
	python:call(P, pathGenerator, register_handler, [self()]),
	python:cast(P,{GridSize, GridSize,AgentsNum, WaitSteps,DispSteps, CS, "Filter", turtle_nop:calculateAllPathsPoints(TurtlesPaths,GridSize, GridSize), TimeOutSec}),
	receive
        Ans->
			begin
%% 				io:format("~w~n", [Ans]),
				python:stop(P),
				io:format(Ans)
			end
	after TimeOutSec*1000 ->
		python:stop(P),
		exit(P, kill),
		"Time-out"
    end.

testQC()->
	Cs1 = {"IN", {"Square", 2}, {"Count", 3}},
	NotCs1 = {"NOT",{"IN", {"Square", 2}, {"Count", 3}}},
	Cs2 = {"IN", {"Circle", 1}, {"Intersection", 1, 3}},
	NotCs2 = {"NOT",{"IN", {"Circle", 1}, {"Intersection", 1,3}}},
	TestCaseNum = 3,
	
	io:format("Testing QC for Constraint: (IN Square 2 Count 3) ~n"),
	testQCwithZ3(Cs1, TestCaseNum),

	io:format("Testing QC for Constraint: (NOT IN Square 2 Count 3) ~n"),
	testQCwithZ3(NotCs1, TestCaseNum),

	io:format("Testing QC for Constraint: (IN Circle 1 Intersection 1 3) ~n"),
	testQCwithZ3(Cs2, TestCaseNum),

	io:format("Testing QC for Constraint: (NOT IN Circle 1 Intersection 1 3) ~n"),
	testQCwithZ3(NotCs2, TestCaseNum).

testQCwithZ3(CS, TestCaseNum)->
	GridSize  = 10,%lists:seq(15,15),
	AgentsNum = 4, %lists:seq(5,20),
	WaitSteps  = 0,
	DispSteps  = 3,%lists:seq(1,20),
	InputNum  = 1,
	TimeOutSec = 60,  % time-out for one repeat, to generate InputNum inputs
	TimeOutMilSec = TimeOutSec*1000,
	
	AllInputs = [ begin
					  {Inputs, _Time} = turtle_nop:forceGetFilteredInputs(GridSize, GridSize, AgentsNum, WaitSteps, DispSteps, CS, InputNum, "erlang", "GenB", TimeOutMilSec),
					   Inputs
				  end 
				|| _I<-lists:seq(1, TestCaseNum)],
	AllInputs2 = lists:filter(fun(X)->X/=timeout end, AllInputs),
	io:format("Test generation is done. Checking the results with z3..~n"),
	TestResults = [begin
					   Ans = isValidInputByZ3(GridSize,AgentsNum,WaitSteps,DispSteps,CS,Inp,TimeOutSec),
					   if (not Ans) -> io:format("Not matched path - not valid by Z3: ~n~w~n",[Inp]);
						  true -> ok
					   end,
					   Ans
				   end	
				   || [Inp] <- AllInputs2], % we have only one input in each element of AllInputs2
	Ans = lists:any(fun(X)->X==false end,TestResults),
	if 
		Ans  -> io:format("QC is NOT successfully matched by z3 for the given constraint.~n");
		true -> io:format("QC is successfully matched by z3 for the given constraint.~n")
	end.
	
	
isValidInputByZ3(GridSize,AgentsNum,WaitSteps,DispSteps,CS,TurtlesPaths, TimeOutSec)->
	{ok, P} = python:start(), 
	python:call(P, pathGenerator, register_handler, [self()]),
	python:cast(P,{GridSize, GridSize,AgentsNum, WaitSteps,DispSteps, CS, "Filter", turtle_nop:calculateAllPathsPoints(TurtlesPaths,GridSize, GridSize), TimeOutSec}),
	receive
        Ans->
			begin
%% 				io:format("~w~n", [Ans]),
				python:stop(P),
				Ans
			end
	after TimeOutSec*1000 ->
		python:stop(P),
		exit(P, kill),
		"Time-out"
    end.


testz3()->
	Cs1 = {"IN", {"Square", 2}, {"Count", 3}},
	NotCs1 = {"NOT",{"IN", {"Square", 2}, {"Count", 3}}},
	Cs2 = {"IN", {"Circle", 1}, {"Intersection", 1, 3}},
	NotCs2 = {"NOT",{"IN", {"Circle", 1}, {"Intersection", 1,3}}},
	TestCaseNum = 6,
	
%% 	io:format("Testing z3 for Constraint: (IN Square 2 Count 3) ~n"),
%% 	testZ3withQC(Cs1, TestCaseNum),
%% 
	io:format("Testing z3 for Constraint: (NOT IN Square 2 Count 3) ~n"), % very time-consuming - decrease parameters' sizes
	% Example: g=5,A=3,w=0,D=2 --> expected time to generate one valid input is 18 seconds
	testZ3withQC(NotCs1, TestCaseNum).
%% 
%% 	io:format("Testing z3 for Constraint: (IN Circle 1 Intersection 1 3) ~n"),
%% 	testZ3withQC(Cs2, TestCaseNum),
%% 
%% 	io:format("Testing z3 for Constraint: (NOT IN Circle 1 Intersection 1 3) ~n"),
%% 	testZ3withQC(NotCs2, TestCaseNum).

testZ3withQC(CS, TestCaseNum)->
	GridSize  = 10,%lists:seq(15,15),
	AgentsNum = 5,%lists:seq(5,20),
	WaitSteps  = 0,
	DispSteps  = 5,%lists:seq(1,20),
%% 	CS = {"IN", {"Square", 2}, {"Count", 5}},
	InputNum  = 1,
	TimeOutSec = 60,  % time-out for one repeat, to generate InputNum inputs
	TimeOutMilSec = TimeOutSec*1000,
	
%% 	{ok, P1} = python:start(), 
%% 	register(pyProcGen, P1),
%% 	{Inputs, _Time} = turtle_nop:forceGetGeneratedInputs(GridSize, GridSize, AgentsNum, WaitSteps, DispSteps, CS, InputNum, TimeOutMilSec),
%% 	exit(P1, kill),
%% 	
%% 	[TurtlesPaths|_Other] = Inputs,
%% 	io:format("~w~n", [TurtlesPaths] ),
%% 	Ans = cshandler:evalCS(GridSize, GridSize, CS, turtle_nop:calculateAllPathsPoints(TurtlesPaths,GridSize, GridSize) ),
%% 	io:format("~w~n", [Ans]).

	io:format("Test generation with z3.. "),
	AllInputs = [ begin
					  	{ok, P1} = python:start(),
						register(pyProcGen, P1), 
					  	{Inputs, _Time} = turtle_nop:forceGetGeneratedInputs(GridSize, GridSize, AgentsNum, WaitSteps, DispSteps, CS, InputNum, TimeOutMilSec),
					   	python:stop(P1), 
					   	exit(P1, kill),
						Inputs
				  end 
				|| _I<-lists:seq(1, TestCaseNum)],
	AllInputs2 = lists:filter(fun(X)->X/=timeout end, AllInputs),
	io:format("Test generation is done. Checking the results with QC..~n"),
	TestResults = [begin
					   Ans = cshandler:evalCS(GridSize, GridSize, CS, turtle_nop:calculateAllPathsPoints(Inp,GridSize, GridSize) ),
					   if (not Ans) -> io:format("Not matched path - not valid by QC: ~n~w~n",[Inp]);
						  true -> ok
					   end,
					   Ans
				   end	
				   || [Inp] <- AllInputs2], % we have only one input in each element of AllInputs2

	Ans = lists:any(fun(X)->X==false end,TestResults),
	if 
		Ans  -> io:format("Z3 is FAILED in matching with QC for the given constraint.~n");
		true -> io:format("Z3 is successfully matched by QC for the given constraint.~n")
	end.






