-module(turtle_nop).
-include_lib("eqc/include/eqc.hrl").	% this library needs installing quickcheck
-compile([export_all, nowarn_export_all]).

%%=====================================================================================================

%% @doc The given arguments will be used by this method to test SUT till reaching the failure, and saves part of 
%%		test results provided by QuickCheck to the file. The output files contain the calculated number of executed
%%		tests, the number of discarded cases, the number of shrinking steps, and the number of failed shrinking steps.
%% @param GridSizes: the list of the sizes of the grid
%% @param TurtleNums: the list of number of turtles that can move on the grid
%% @param NumOfRuns: the number of test runs
%% @param NumOfTestCases: the maximum number of test cases that failures is expected to happen before that
%% @param PathActionSteps: the length of displacement actions in the grid that each turtle has during tests
%% @param PathWaitSteps: the length of waiting actions in the grid that each turtle has during tests
%% @param PropertyNum: It is the number of property that defines the filtering criteria of tests. Currently
%%					   it can only be 0,1,2, and 3:
%%							The value 0 does not filter any test cases. 
%%							The value 1, 2 and 3 filter the inputs based on the defined filters F1, F2 and F3.
%%							The value -1 makes a new filter be used given in the FileterFunc parameter.
%% @param Path: the relative directory address that the results will be saved in file system based on that
%% @param FileterFunc: It is the filtering function for test input selection. In order to apply this function, PropertyNum is needed
%%					   to be -1. This method should take a list of turtlePaths as input and return a boolean value as output.
%%					   If the result of applying this function to a reandomly generated list of turtlePaths is true, that case will
%%					   go for testing (on the SUT), dropped from testing otherwise.

%% executing the experiment with the defined parameters and saving the results in 'NoFilter', 'F1', 'F2', and 'F3' folders
experiment1()->
	GridSize = 50,
 	TurtleNum = 5,
 	NumOfRuns = 10,    
 	NumOfTestCases = 100000, %% if the test is not failed before this number of inputs, the test will supposed as passed one
 	PathActionSteps=5,
	PathWaitSteps = 5,
 	io:fwrite("~n~nTesting with no filter:~n~n"),
  	experiment1([GridSize],[TurtleNum], NumOfRuns, NumOfTestCases, PathActionSteps, PathWaitSteps, true, filename:join(["Exp I - results","NoFilter"])),
	io:fwrite("~n~nTesting with filter F1:~n~n"),
	timer:sleep(2000),
	experiment1([GridSize],[TurtleNum], NumOfRuns, NumOfTestCases, PathActionSteps, PathWaitSteps, {"IN", {"Circle", 5}, {"Count", 2}}, filename:join(["Exp I - results","F1"])),
	io:fwrite("~n~nTesting with filter F2:~n~n"),
	timer:sleep(2000),
	experiment1([GridSize],[TurtleNum], NumOfRuns, NumOfTestCases, PathActionSteps, PathWaitSteps, {"IN", {"Circle", 3}, {"Count", 2}}, filename:join(["Exp I - results","F2"])),
	io:fwrite("~n~nTesting with filter F3:~n~n"),
	timer:sleep(2000),
 	experiment1([GridSize],[TurtleNum], NumOfRuns, NumOfTestCases, PathActionSteps, PathWaitSteps, {"IN", {"Circle", 3}, {"Intersection", 1,2}}, filename:join(["Exp I - results","F3"])).

experiment1(GridSizes,TurtleNums, NumOfRuns, NumOfTestCases)->
	experiment1(GridSizes,TurtleNums, NumOfRuns, NumOfTestCases, 10, 10, true, "Results").

experiment1(GridSizes,TurtleNums, NumOfRuns, NumOfTestCases, PathActionSteps, PathWaitSteps)->
	experiment1(GridSizes,TurtleNums, NumOfRuns, NumOfTestCases, PathActionSteps, PathWaitSteps, 0, "Results").

experiment1(GridSizes,TurtleNums, NumOfRuns, NumOfTestCases, PathActionSteps, PathWaitSteps, FilteringConstraint)->
	experiment1(GridSizes,TurtleNums, NumOfRuns, NumOfTestCases, PathActionSteps, PathWaitSteps, FilteringConstraint, "Results").

experiment1(GridSizes,TurtleNums, NumOfRuns, NumOfTestCases, PathActionSteps, PathWaitSteps, FilteringConstraint, RootFilePathAddress)->
	
	Time1 = erlang:timestamp(),
	Res = cleanRunsAll_propCollision(GridSizes,TurtleNums,NumOfRuns,NumOfTestCases,PathActionSteps, PathWaitSteps,FilteringConstraint),
	Time2 = erlang:timestamp(),
	TimeDiff = timer:now_diff(Time2, Time1) div 1000000,
	%io:fwrite("Results: ~w~n",[Res]),
	io:fwrite("Testing the property is done.~nIt took ~w seconds.~n",[TimeDiff]),
	filelib:ensure_dir(filename:join([RootFilePathAddress, "Time.txt"])), 
	{ok,S} = file:open(filename:join([RootFilePathAddress, "Time.txt"]), [write]),
	io:format(S, "Test execution took ~w seconds.~n", [TimeDiff]),
	
	filelib:ensure_dir(filename:join([RootFilePathAddress, "Raw", "TestsNum.txt"])), 
	filehelper:writeFileResults_exp1Format(filename:join([RootFilePathAddress, "Raw", "TestsNum.txt"]), "ansNumTests", Res, GridSizes,TurtleNums),
	filehelper:writeFileResults_exp1Format(filename:join([RootFilePathAddress, "Raw", "FailedShrinkSteps.txt"]), "ansFailedShrinkSteps", Res,GridSizes, TurtleNums),
	filehelper:writeFileResults_exp1Format(filename:join([RootFilePathAddress, "Raw", "ShrinkSteps.txt"]), "ansShrinkSteps", Res, GridSizes,TurtleNums),
	filehelper:writeFileResults_exp1Format(filename:join([RootFilePathAddress, "Raw", "Discards.txt"]), "ansDiscards", Res, GridSizes,TurtleNums),
	
	Ans = statisticshelper:getQuartileChartsData_forGrids(Res), 
	%filelib:ensure_dir("Results//Quartiles//"), 
	filelib:ensure_dir(filename:join([RootFilePathAddress, "Quartiles", "TestsNum.txt"])), 
	filehelper:writeFileResults_exp1Format(filename:join([RootFilePathAddress, "Quartiles", "TestsNum.txt"]), "ansNumTests", Ans, GridSizes,TurtleNums),
	filehelper:writeFileResults_exp1Format(filename:join([RootFilePathAddress, "Quartiles", "FailedShrinkSteps.txt"]), "ansFailedShrinkSteps", Ans,GridSizes, TurtleNums),
	filehelper:writeFileResults_exp1Format(filename:join([RootFilePathAddress, "Quartiles", "ShrinkSteps.txt"]), "ansShrinkSteps", Ans, GridSizes,TurtleNums),
	filehelper:writeFileResults_exp1Format(filename:join([RootFilePathAddress, "Quartiles", "Discards.txt"]), "ansDiscards", Ans, GridSizes,TurtleNums),
	
	Ans2 = statisticshelper:getAVGChartsData_forGrids(Res),
	io:fwrite("Avg Calculations are done.~n"),
	
	%filelib:ensure_dir("Results//Avg//"), 
	filelib:ensure_dir(filename:join([RootFilePathAddress, "Avg", "TestsNum.txt"])), 
	filehelper:writeFileResults_exp1Format(filename:join([RootFilePathAddress, "Avg", "TestsNum.txt"]), "ansNumTests", Ans2, GridSizes,TurtleNums),
	filehelper:writeFileResults_exp1Format(filename:join([RootFilePathAddress, "Avg", "FailedShrinkSteps.txt"]), "ansFailedShrinkSteps", Ans2,GridSizes, TurtleNums),
	filehelper:writeFileResults_exp1Format(filename:join([RootFilePathAddress, "Avg", "ShrinkSteps.txt"]),  "ansShrinkSteps", Ans2, GridSizes,TurtleNums),
	filehelper:writeFileResults_exp1Format(filename:join([RootFilePathAddress, "Avg", "Discards.txt"]), "ansDiscards", Ans2, GridSizes,TurtleNums),

	io:fwrite("The results are saved in separated files.~n").

%%=====================================================================================================


%%=====================================================================================================

%% @doc This method runs tests for the given different grid sizes and number of turtles in the grid
%% @returns a list of lists. 
%%			Each memeber of that is the list of executing 'cleanRunsForTurtles_propCollision' function for one of the given
%%			grid sizes and all of the given turtle numbers.
%%			The result of of the execution for one grid size and one turtles number is a record having the following structure.
%%			#{
%%				ansDiscards				---> a list which is a collection of 'ansDiscards' items in each test suit execution results 
%%	 			ansNumTests,			---> a list which is a collection of 'ansNumTests' items in each test suit execution results
%%				ansFailedShrinkSteps ,	---> a list which is a collection of 'ansFailedShrinkSteps' items in each test suit execution results
%%				ansShrinkSteps	  		---> a list which is the collection of 'ansShrinkSteps' items in each test suit execution results
%%			}

cleanRunsAll_propCollision(GridSizes, TurtlesNums,NumOfRuns,NumOfTestCases,PathActionSteps, PathWaitSteps,FilteringConstraint)->
	[cleanRunsForTurtles_propCollision(GridSize, TurtlesNums,NumOfRuns,NumOfTestCases,PathActionSteps, PathWaitSteps,FilteringConstraint) || GridSize<-GridSizes].

cleanRunsForTurtles_propCollision(GridSize, TurtleNums,NumOfRuns,NumOfTestCases,PathActionSteps, PathWaitSteps,FilteringConstraint)->
%% 	case PropertyNum of
%% 		-1	-> FilterFunction = FileterFunc;
%% 		0	-> FilterFunction = fun(_TurtlesPaths) -> true end;
%% 		1	-> FilterFunction = fun(TurtlesPaths)  -> checkMinDistanceOfAllPaths(calculateAllPathsPoints(TurtlesPaths, GridSize,GridSize),10) end;
%% 		2	-> FilterFunction = fun(TurtlesPaths)  -> checkMinDistanceOfAllPaths(calculateAllPathsPoints(TurtlesPaths, GridSize,GridSize),6) end;
%% 		3	-> FilterFunction = fun(TurtlesPaths)  -> existsCommonInAllPaths(calculateAllPathsPoints(TurtlesPaths, GridSize,GridSize)) end
%% 	end,

%% 	case PropertyNum of
%% 		-1	-> FilterFunction = FileterFunc;
%% 		0	-> FilterFunction = fun(_TurtlesPaths) -> true end;
%% 		%1	-> FilterFunction = fun(TurtlesPaths)  -> cshandler:evalCS(GridSize, GridSize, {"IN", {"Circle", 5}, {"Count", 2}}, TurtlesPaths ) end;
%% 		1	-> FilterFunction = fun(TurtlesPaths)  -> pathFilterWithZ3(GridSize, GridSize, TurtleNums, PathWaitSteps, PathActionSteps, {"IN", {"Circle", 5}, {"Count", 2}}, TurtlesPaths) end;
%% 		2	-> FilterFunction = fun(TurtlesPaths)  -> cshandler:evalCS(GridSize, GridSize, {"IN", {"Circle", 3}, {"Count", 2}}, TurtlesPaths ) end;
%% 		3	-> FilterFunction = fun(TurtlesPaths)  -> cshandler:evalCS(GridSize, GridSize, {"IN", {"Circle", 1}, {"Intersection", 1,2}}, TurtlesPaths ) end     
%% 	end,
%% 	
	[cleanRuns_propCollision(GridSize, TurtleNum,NumOfRuns,NumOfTestCases,PathActionSteps, PathWaitSteps,FilteringConstraint) || TurtleNum<-TurtleNums].

%%=====================================================================================================

%%=====================================================================================================

%% @doc This method runs tests for one grid size and one particular number of turtles on the grid
%% @precondition Tests are expected to find the fault (be failed) by running at most 'NumOfTestCases' tests
%% @returns the cleaned data of test execution resutls
%%			The return data has the following format:
%%			#{
%%				ansDiscards				---> a list which is a collection of 'ansDiscards' items in each test suit execution results 
%%	 			ansNumTests,			---> a list which is a collection of 'ansNumTests' items in each test suit execution results
%%				ansFailedShrinkSteps ,	---> a list which is a collection of 'ansFailedShrinkSteps' items in each test suit execution results
%%				ansShrinkSteps	  		---> a list which is the collection of 'ansShrinkSteps' items in each test suit execution results
%%			}

cleanRuns_propCollision(GridSize,TurtlesNum,NumOfRuns,NumOfTestCases,PathActionSteps, PathWaitSteps,FilteringConstraint) ->
    TestsExecInfo = run_propCollision(NumOfRuns, GridSize, TurtlesNum,NumOfTestCases,PathActionSteps, PathWaitSteps,FilteringConstraint, []), % a list of records
	cleanAndCombineInfo_PropCollision(TestsExecInfo). % cleaning the properties of no interest, combining records to one record that each of its elements is a list          

%%=====================================================================================================

%%=====================================================================================================

%% @doc This method executes given number of test sets for the given SUT parameters
%% @param TestsExecInfo stores the result of tests' executions in each call and gets completed in different calls of the method
%% @returns a list of records, which each record contains the following items:
%%			#{
%%	  			aggregated_data,
%%	  			measurements,
%%	  			reason,
%%	  			result,
%%	  			statistics,
%%	  			user_info
%%	 		}
%%			Each of these items has their own type.
%%			Among these information, the item 'statistics' is of interests to us 
%%			that has a record type with the follwing structure:
%%			#{
%%	  			discards,				----> an integer, as the number of discarded test inputs by filtering
%%	  			failed_shrinksteps,   	----> an integer, as the number of failed shrinking steps
%%	  			numtests,				----> an integer, as the number of executed tests to reach a pass/fail conlusion
%%	  			outcome,				----> a boolean, as if the test was successful or not
%%	  			shrinksteps				----> an integer, as the number of successful shrinking steps to reach the most shrunk test case
%%											  For successful tests, we do not have shrinking.
%%	 		} 

run_propCollision(0, _,_,_,_,_,_, TestsExecInfo) -> 
    TestsExecInfo;

run_propCollision(NumOfRuns, GridSize, TurtlesNum,NumOfTestCases,PathActionSteps, PathWaitSteps,FilteringConstraint, TestsExecInfo) ->
	ExecInfo = counterexample(numtests(NumOfTestCases,propCollision(GridSize, TurtlesNum, PathActionSteps, PathWaitSteps,FilteringConstraint)), [{with_info, true}]),
	run_propCollision(NumOfRuns - 1, GridSize, TurtlesNum,NumOfTestCases,PathActionSteps, PathWaitSteps,FilteringConstraint, [ExecInfo | TestsExecInfo]).

%%=====================================================================================================

%%=====================================================================================================
%% @doc This method defines a quickcheck property, executes that on our SUT and returned some gathered information
%%		from the test execution. Then, it checks that the movement of turtles will lead to any collision for any of the turtles.
%%		It will return the detailed information of the test execution at the end.
%% @returns A record containing the following items
%%			#{
%%	  			aggregated_data,
%%	  			measurements,
%%	  			reason,
%%	  			result,
%%	  			statistics,
%%	  			user_info
%%	 		}
%%			Each of these items has their own type.
%%			Among these information, the item 'statistics' is of more interests to us 
%%			that has a record type with the follwing structure:
%%			#{
%%	  			discards,				----> an integer, as the number of discarded test inputs by filtering
%%	  			failed_shrinksteps,   	----> an integer, as the number of failed shrinking steps
%%	  			numtests,				----> an integer, as the number of executed tests to reach a pass/fail conlusion
%%	  			outcome,				----> a boolean, as if the test was successful or not
%%	  			shrinksteps				----> an integer, as the number of successful shrinking steps to reach the most shrunk test case
%%											  For successful tests, we do not have shrinking.
%%	 		} 

propCollision(GridSize, TurtlesNumbers, PathActionSteps, PathWaitSteps, FilteringConstraint) ->
    MaxX = GridSize,
    MaxY = GridSize,
	if
		FilteringConstraint==true -> FilterFunction = fun(_TurtlesPaths) -> true end;
		true					  -> FilterFunction = fun(TurtlesPaths) -> cshandler:evalCS(GridSize, GridSize, FilteringConstraint, TurtlesPaths) end
	end,
%% 	noshrink(
	  ?FORALL(TurtlesPaths, 
			  turtlesPaths_gen_A(MaxX, MaxY, TurtlesNumbers, PathActionSteps, PathWaitSteps),
			 %?IMPLIES(FilterFunction(TurtlesPaths),
			 ?IMPLIES(FilterFunction( calculateAllPathsPoints (TurtlesPaths, MaxX, MaxY) ),
					 %false)
					 begin
		                Trace = turtlesworld2:run(TurtlesPaths, MaxX, MaxY),
						?WHENFAIL(%eqc:format("Trace =~p\n", [Trace]), ?WHENFAIL(Action,Prop) : performs Action (for its side effects) when Prop fails.
								  io:format(""),
		                          begin
		                              Result = not lists:keymember({event, collision}, 1, Trace),
									  %user_info(Key::atom(), FunOrData::fun((any()) -> any()), Prop::property()) -> property()
		                              user_info(trace_length,
		                                        fun
												   (undefined) 	when not Result -> [{length(TurtlesPaths),length(Trace)}];
		                                           (V) 			when not Result -> V ++ [{length(TurtlesPaths),length(Trace)}];
		                                           (V) 							-> V
		                                        end, 
												Result)
		
		                           end)
		           	  end)
			 ).
%% 	).


%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

prop2(GridSize, TurtlesNumbers, PathActionSteps, PathWaitSteps, CS, FilterType, GenType) ->
    MaxX = GridSize,
    MaxY = GridSize,
	if
		FilterType== "erlang" -> FilterFunction = fun(TurtlesPaths) -> cshandler:evalCS(GridSize, GridSize, CS, TurtlesPaths ) end;
													 
		FilterType== "z3"     -> FilterFunction = fun(TurtlesPaths) -> pathFilterWithZ3(GridSize, GridSize, TurtlesNumbers, PathWaitSteps, PathActionSteps, CS, TurtlesPaths) end
	end,
		
	noshrink(
	  ?FORALL(TurtlesPaths, 
			  begin
				  	if 
						GenType == "GenA" -> turtlesPaths_gen_A(MaxX, MaxY, TurtlesNumbers, PathActionSteps, PathWaitSteps) ;
						GenType == "GenB" -> turtlesPaths_gen_B(MaxX, MaxY, TurtlesNumbers, PathActionSteps, PathWaitSteps)
					end
			  end,
			  ?IMPLIES(FilterFunction( calculateAllPathsPoints (TurtlesPaths, MaxX, MaxY) ),
					 begin
		                Trace = turtlesworld2:run(TurtlesPaths, MaxX, MaxY),
						?WHENFAIL(io:format(""),
		                          begin
		                              Result = not lists:keymember({event, collision}, 1, Trace),
		                              user_info(trace_length,
		                                        fun
												   (undefined) 	when not Result -> [{length(TurtlesPaths),length(Trace)}];
		                                           (V) 			when not Result -> V ++ [{length(TurtlesPaths),length(Trace)}];
		                                           (V) 							-> V
		                                        end, 
												Result)
		
		                           end)
		           	  end)
			 )%.
	).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

propFilter(GridSize, TurtlesNumbers, PathActionSteps, PathWaitSteps, CS) ->
    MaxX = GridSize,
    MaxY = GridSize,
	FilterFunction = fun(TurtlesPaths) -> (cshandler:evalCS(GridSize, GridSize, CS, TurtlesPaths ) or true) end,
		
	noshrink(
	  ?FORALL(TurtlesPaths, 
			  turtlesPaths_gen_B(MaxX, MaxY, TurtlesNumbers, PathActionSteps, PathWaitSteps),
			  ?IMPLIES(FilterFunction( calculateAllPathsPoints (TurtlesPaths, MaxX, MaxY) ),
					 true
			  )
			 )%.
	).

getFilteringTime()->
	GridSizes  = [10,20,50,100],%lists:seq(15,15),
	AgentsNum = 5,%lists:seq(5,20),
	WaitSteps  = 5,
	DispSteps  = 5,%lists:seq(1,20),,
	F1 = {"IN", {"Circle", 5}, {"Count",2}},
	F2 = {"IN", {"Circle", 3}, {"Count",2}},
	F3 = {"IN", {"Circle", 1}, {"Intersection",1, 2}},
	CSs = [F1,F2,F3],
	FileName = filename:join(["Exp1-results","FilteringTimes.txt"]),
	filelib:ensure_dir(FileName),
	{ok, MyFileTime} = file:open(FileName, [write]),
	Repeat = 100,
	[begin
		Time1 = erlang:timestamp(),
	  	eqc_suite:random(numtests(Repeat,propFilter(GridSize,AgentsNum, DispSteps, WaitSteps, CS))),
		Time2 = erlang:timestamp(),
		DifTime = timer:now_diff (Time2, Time1) div 1000, % milli seconds
		Avg = DifTime div Repeat,
		if 
			CS == {"IN", {"Circle", 5}, {"Count",2}} -> Filter = "F1";
			CS == {"IN", {"Circle", 3}, {"Count",2}} -> Filter = "F2";
			CS == {"IN", {"Circle", 1}, {"Intersection",1, 2}} -> Filter ="F3"
		end,
		io:format(MyFileTime, "Average time of filtering by ~s in grid ~w is ~w milli second(s)~n", [Filter,GridSize,Avg] )
	 end
	|| CS<-CSs, GridSize<-GridSizes].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

qcGenPerformance()->
%% 	{ok, P1} = python:start(), 
%% 	register(pyProcGen, P1),
	
%% 	{ok, P2} = python:start(),
%% 	register(pyProcFil, P2),
			
	GridSizes  = [10,15,20,50],%lists:seq(15,15),
	AgentsNums = [10,15,20],%lists:seq(5,20),
	WaitSteps  = 0,
	DispStepss  = [1,5,10,15,20],%lists:seq(1,20),
	InputNum  = 1,
	AreaType = "Square",
	AreaSize = 2,
	ConditionType = "Count", % "Intersection", 
%% 	NumOccurrances = 1,
	Degree = 3,
%% 	CS = {"IN", {AreaType, AreaSize}, {ConditionType, NumOccurrances, Degree}}, % for intersection type
	CS = {"IN", {AreaType, AreaSize}, {ConditionType, Degree}}, % for count type
	CS_folderName = "IN "++ AreaType ++ " " ++ integer_to_list(AreaSize) ++ " " ++ ConditionType ++ 
%% 						" " ++ integer_to_list(NumOccurrances) ++    %uncomment for intersection type - comment for count type
						" " ++ integer_to_list(Degree),
	RepeatExp = 30,
	TimeOutSec = 60,  % time-out for one repeat, to generate InputNum inputs

%% 	expPaper2Run(20, 20, 20, 20, 1, CS, "BadData", 1, 1 ),
	[expPaper2Run(GridSize, AgentsNum, WaitSteps, DispSteps, InputNum, CS, CS_folderName, RepeatExp, TimeOutSec )
	 ||  GridSize<-GridSizes,AgentsNum<- AgentsNums, DispSteps<-DispStepss ],

%% 	Proc1 = whereis(pyProcGen),
%% 	exit(Proc1, kill),

%% 	Proc2 = whereis(pyProcFil),
%% 	exit(Proc2, kill),
	io:fwrite("Exp2 is Done!").
	
	

expPaper2Run(GridSize, AgentsNum, WaitSteps, DispSteps, InputNum, CS, CS_folderName, RepeatExp, TimeOutSec )->
		
	FolderNameTimes  = filename:join(["Exp II - results", "qc-erlang", "GenTimes" , CS_folderName]),
	FolderNameInputs = filename:join(["Exp II - results", "qc-erlang", "GenInputs", CS_folderName]),
	ExpInfo=  "G-"++integer_to_list(GridSize) ++
			 "-A-"++integer_to_list(AgentsNum)++
			 "-W-"++integer_to_list(WaitSteps)++
			 "-D-"++integer_to_list(DispSteps)++
			 "-I-"++integer_to_list(InputNum) ++
		     "-R-"++integer_to_list(RepeatExp)++
			 "-T-"++integer_to_list(TimeOutSec),
	
	io:fwrite("~nStarting Data Generation for "++ ExpInfo++ "~n~n"),
	TimeOutMilSec = TimeOutSec*1000, % milli second
	
%% 	Results1 = [getFilteredInputs(GridSize, GridSize, AgentsNum, WaitSteps, DispSteps, CS, InputNum, "erlang", "GenA") || _I<-lists:seq(1, RepeatExp)],
%% 	FileName1 = filename:join([FolderName, FileNamePrefix++"Fil-Erl-GenA.txt"]),
%% 	saveToFile(Results1, FileName1),
%% 	io:fwrite("~nFiltering with erlang code-GenA is done and saved in a file. ~n~n"),
%% 	timer:sleep(2000),
	
	Results2 = [forceGetFilteredInputs(GridSize, GridSize, AgentsNum, WaitSteps, DispSteps, CS, InputNum, "erlang", "GenB", TimeOutMilSec) || _I<-lists:seq(1, RepeatExp)],
	FileNameTimes2  = filename:join([FolderNameTimes,  ExpInfo++"-Fil-Erl-GenB.txt"]),
	FileNameInputs2 = filename:join([FolderNameInputs, ExpInfo++"-Fil-Erl-GenB.txt"]),
	saveTimesToFile( Results2, FileNameTimes2),
	saveInputsToFile(Results2, FileNameInputs2),
	io:fwrite("~nFiltering with erlang code-GenB is done and saved in a file. ~n~n"),
	timer:sleep(1000),
	
%% 	Results3 = [getFilteredInputs(GridSize, GridSize, AgentsNum, WaitSteps, DispSteps, CS, InputNum, "z3", "GenB") || _I<-lists:seq(1, RepeatExp)],
%% 	FileName3 = filename:join([FolderName, FileNamePrefix++"Fil-z3-GenB.txt"]),
%% 	saveToFile(Results3, FileName3),
%% 	io:fwrite("Filtering with z3 code is done and saved in a file. ~n~n"),
	
%% 	Results4 = [forceGetGeneratedInputs(GridSize, GridSize, AgentsNum, WaitSteps, DispSteps, CS, InputNum, TimeOutMilSec) || _I<-lists:seq(1, RepeatExp)],
%% 	FileNameTimes4  = filename:join([FolderNameTimes,  ExpInfo++"-Gen-Z3.txt"]),
%% 	FileNameInputs4 = filename:join([FolderNameInputs, ExpInfo++"-Gen-Z3.txt"]),
%% 	saveToFile(Results4, FileNameTimes4, FileNameInputs4),
%% 	io:fwrite("Generating with z3 code is done and saved in a file. ~n~n"),
%% 	timer:sleep(1000),
	
	io:fwrite("~nFinished Data Generation for "++ ExpInfo ++ "~n~n").


saveTimesToFile(Results, FileNameTime)->
	filelib:ensure_dir(FileNameTime), 
	TimesAll = [Time || {_Inputs, Time}<-Results],
	L = length(TimesAll),
	{ok, MyFileTime} = file:open(FileNameTime, [write]),
	io:format(MyFileTime,  "All Times:~n",  []),
	[io:format(MyFileTime, "Test Set ~2w:~7w~n", [TimeIndex, lists:nth(TimeIndex, TimesAll)] )|| TimeIndex<-lists:seq(1, L)],
	io:format(MyFileTime,  "~nStatistics:~n", []),
	io:format(MyFileTime,  "~-20s:~7w~n", ["Total",lists:sum(TimesAll)] ),
	io:format(MyFileTime,  "~-20s:~7w~n", ["Average",lists:sum(TimesAll) div L] ),
	SortedTimesAll = lists:sort(TimesAll),
	if 
		length(SortedTimesAll)>2 -> 
			begin
				NoMinMaxTimesAll = lists:sublist(SortedTimesAll, 2, length(SortedTimesAll)-2),
				io:format(MyFileTime,  "~-20s:~7w~n", ["Average (no Min/Max)", lists:sum(NoMinMaxTimesAll) div length(NoMinMaxTimesAll)] )
			end;
		true -> io:format(MyFileTime,  "~-20s:~7w~n", ["Average (no Min/Max)", "---"] )
	end,
	
	if
		(L rem 2)==0 -> Median = ( lists:nth(L div 2, SortedTimesAll) + lists:nth( 1+ (L div 2), SortedTimesAll) ) div 2;
		true		 -> Median =   lists:nth(1+(L div 2), SortedTimesAll)
	end,
	io:format(MyFileTime,  "~-20s:~7w~n", ["Median", Median] ),
	file:close(MyFileTime).

saveInputsToFile(Results, FileNameInputs)->
	filelib:ensure_dir(FileNameInputs),
	TestInputSetsAll = [TestInputSet|| {TestInputSet, _Time}<-Results],
	{ok, MyFileInput} = file:open(FileNameInputs, [write]),
	saveInputSetsToFile(TestInputSetsAll, MyFileInput, 1),
	file:close(MyFileInput).
	

forceGetGeneratedInputs(GridSize, GridSize, AgentsNum, WaitSteps, DispSteps, CS, InputNum, MaxTimeMilliSec)->
	begin
		Time1 = erlang:timestamp(),
		Pid = spawn(turtle_nop, returnGeneratedInputs, [self(), GridSize, GridSize, AgentsNum, WaitSteps, DispSteps, CS, InputNum, MaxTimeMilliSec]),        
		receive
			Inputs->
				Time2 = erlang:timestamp(),
%% 				DifTime = timer:now_diff (Time2, Time1) div 1000000, % seconds
				DifTime = timer:now_diff (Time2, Time1) div 1000, % milli seconds
				{Inputs, DifTime}
		after MaxTimeMilliSec ->
			exit(Pid, kill),
			PyPid = whereis(pyProcGen),
			if 
				PyPid == undefined -> ok; % it has already stopped somehow
				true -> begin
							python:stop(PyPid),		% avoiding the previous process to continue solving the constraints anymore
							exit(PyPid, kill),
							{ok, P1} = python:start(), 
							register(pyProcGen, P1)
						end
			end,
			io:format("~n~nTime out!~n~n"),
%% 			{timeout, MaxTimeMilliSec div 1000}  % return timeout after no result for inputNum test inputs
			{timeout, MaxTimeMilliSec}  % return timeout after no result for inputNum test inputs
		end
	 end.

returnGeneratedInputs(Pid, GridSize, GridSize, AgentsNum, WaitSteps, DispSteps, CS, InputNum, MaxTimeMilliSec)->
	Pid ! pathGenWithZ3(GridSize, GridSize, AgentsNum, WaitSteps, DispSteps, CS, InputNum, MaxTimeMilliSec).

pathGenWithZ3(GridX, GridY, AgentsNum, WaitSteps, DispSteps, CSs,InputNum, MaxTimeMilliSec)->
%% 	{ok, P} = python:start(), % calling python 3 (python 2 throws some errors)
%% 	register(pyProcGen, P),
	P = whereis(pyProcGen),
	python:call(P, pathGenerator, register_handler, [self()]),
	python:cast(P,{GridX, GridY,AgentsNum, WaitSteps,DispSteps, CSs, "Gen", InputNum, MaxTimeMilliSec div 1000}),
	receive
        R->
			begin
%% 				python:stop(P),
				R
			end
    end.

forceGetFilteredInputs(GridSize, GridSize, AgentsNum, WaitSteps, DispSteps, CS, InputNum, FilterType, GenType, MaxTimeMilliSec)->
	Time1 = erlang:timestamp(),
	Pid = spawn(turtle_nop, returnFilteredInputs, [self(), GridSize, GridSize, AgentsNum, WaitSteps, DispSteps, CS, InputNum, FilterType,GenType, []]),        
	receive
		Inputs->
			Time2 = erlang:timestamp(),
%% 			DifTime = timer:now_diff (Time2, Time1) div 1000000, % seconds
			DifTime = timer:now_diff (Time2, Time1) div 1000, % milli seconds
			{Inputs, DifTime}
	after MaxTimeMilliSec ->
		exit(Pid, kill),
		PyPid = whereis(pyProcFil),
		if 
			PyPid == undefined -> ok; % if Gentype!= Z3 or it has already stopped somehow
			true -> begin
						python:stop(PyPid),
						{ok, P1} = python:start(), 
						register(pyProcFil, P1)
					end
		end,
		io:format("~n~nTime out!~n~n"),
%% 		{timeout, MaxTimeMilliSec div 1000}  % return timeout after no result for inputNum test inputs
		{timeout, MaxTimeMilliSec}
	end.

returnFilteredInputs(Pid, GridSize, GridSize, AgentsNum, WaitSteps, DispSteps, CS, InputNum, FilterType, GenType, AnsInput)->
	Pid ! getFilteredInputs(GridSize, GridSize, AgentsNum, WaitSteps, DispSteps, CS, InputNum, FilterType, GenType, AnsInput).

getFilteredInputs(GridSize, GridSize, AgentsNum, WaitSteps, DispSteps, CS, InputNum, FilterType, GenType, AnsInput)->
	RequiredNewCases = InputNum - length(AnsInput),
	if
		RequiredNewCases > 0 ->
			begin
				{_,NewInputs} = eqc_suite:random(numtests(RequiredNewCases,prop2(GridSize,AgentsNum, DispSteps, WaitSteps, CS, FilterType, GenType ))),
				CleanedInputs = [Inp||[Inp|[]]<-NewInputs],
%% 				io:fwrite("new inputs:~w~n",[CleanedInputs]),
%% 				io:fwrite("~w number of inputs are generated in total.~n", [length(AnsInput++NewInputs)]),
				getFilteredInputs(GridSize, GridSize, AgentsNum, WaitSteps, DispSteps, CS, InputNum, FilterType, GenType, AnsInput++CleanedInputs)
			end;
		true->
			AnsInput
	end.

saveInputSetsToFile([OneSetOfInputs|[]], MyFile, SetNum)->
	io:format(MyFile, "Repeat Index:~w~n~n~n",[SetNum]),
	if 
		OneSetOfInputs==timeout-> io:format(MyFile, "Time-out~n~n~n",[]);
	 	true-> begin
%% 				   CleanedSetOfInputs = [ Input || [Input|[]]<- OneSetOfInputs],
%% 				   saveInputsToFile(CleanedSetOfInputs, MyFile, 1)
			   	   saveInputsToFile(OneSetOfInputs, MyFile, 1)
			   end
	 end;

saveInputSetsToFile([OneSetOfInputs|OtherSets], MyFile, SetNum)->
	io:format(MyFile, "Repeat Index:~w~n~n~n",[SetNum]),
	if 
		OneSetOfInputs==timeout-> io:format(MyFile, "Time-out~n~n~n",[]);
	 	true-> begin
%% 				   CleanedSetOfInputs = [ Input || [Input|[]]<- OneSetOfInputs],
%% 				   saveInputsToFile(CleanedSetOfInputs, MyFile, 1)
			   	   saveInputsToFile(OneSetOfInputs, MyFile, 1)
			   end
	 end,
	saveInputSetsToFile(OtherSets, MyFile, SetNum+1).

% we need at least one moving step
saveInputsToFile( [OneInput|[]], MyFile, TestInputNum)->
	io:format(MyFile, "Test input:~w~n",[TestInputNum]),
%% 	PathsStr = [pathToString(OnePath)||OnePath<-OneInput],
%% 	[io:format(MyFile, "~s~n", [Path]) || Path<-PathsStr],
	[begin
		case OnePath of
			{Num, StartX, StartY, Moves} ->
				begin
					[FirstMove|OtherMoves] = Moves,
					 io:format(MyFile, "AgentNum=~3w; Start(~2w,~2w); Moves=~-5w", [Num,StartX,StartY,FirstMove]),
					[io:format(MyFile,",~-5w",[OneMove])|| OneMove<-OtherMoves],
					 io:format(MyFile,"~n",[])
				end;
			timeout->
				io:format(MyFile,"time-out~n",[])
		end
	 end ||OnePath<-OneInput],
	io:format(MyFile, "~n~n", []);

saveInputsToFile( [OneInput|Other], MyFile, TestInputNum)->
	io:format(MyFile, "Test input:~w~n",[TestInputNum]),
%% 	PathsStr = [pathToString(OnePath)||OnePath<-OneInput],
%% 	[io:format(MyFile, "~s~n", [Path]) || Path<-PathsStr],
	
	[begin
		case OnePath of
			{Num, StartX, StartY, Moves} ->
				begin
					[FirstMove|OtherMoves] = Moves,
					io:format( MyFile, "AgentNum=~3w; Start(~2w,~2w); Moves=~-5w", [Num,StartX,StartY,FirstMove]),
					[io:format(MyFile,",~-5w",[OneMove])|| OneMove<-OtherMoves],
					io:format( MyFile,"~n",[])
				end;
			timeout->
				io:format(MyFile,"time-out~n",[])
		end
	 end ||OnePath<-OneInput],
	
	io:format(MyFile, "~n~n", []),
	saveInputsToFile(Other, MyFile, TestInputNum+1).
		
pathToString(OnePath)->
%% 	io:fwrite("~n~nOne Path:~w~n",[OnePath]),
	case OnePath of
		{Num, StartX, StartY, Moves} ->
			begin
				StrMovesList = [atom_to_list(Move)||Move<-Moves],
				StrMoves2 = lists:foldl(fun(NewElement, Sum)-> Sum ++ "," ++ NewElement end, "", StrMovesList),
				StrMoves = string:sub_string(StrMoves2, 2),
				"AgentNum="++integer_to_list(Num) ++ "; Start=(" ++ integer_to_list(StartX) ++ "," ++ integer_to_list(StartY)++ "); Moves=" ++ StrMoves
			end;
		timeout->
			"time-out"
	end.
		
			

%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%% exp1CSgenerator()->
%% 	GridX = 10,
%% 	GridY = 10,
%% 	AgentsNum = 5,
%% 	WaitSteps = 0,
%% 	DispSteps = 5,
%% 	InputNum = 10,
%% 	CSs = {"IN", {"Circle", 3}, {"Count", 2}},
%% 	TestInputs = pathGenWithZ3(GridX, GridY, AgentsNum, WaitSteps, DispSteps, CSs, InputNum),
%% %% 	TestResults = [begin
%% %% 					   Trace = turtlesworld2:run(TestInput, GridX, GridY),
%% %% 					   not lists:keymember({event, collision}, 1, Trace)
%% %% 				   end
%% %% 				  ||TestInput<-TestInputs],
%% 	FilterAns = [cshandler:evalCS(GridX, GridY, CSs, calculateAllPathsPoints(TestInput, GridX, GridY) )
%% 				||TestInput<-TestInputs],
%% %% 	[io:fwrite("Set of Paths:~n~w~n",[Inp]) || Inp<-TestInputs],
%% 	io:fwrite("Results:~n~w~n",[FilterAns]).
	
		   
pathFilterWithZ3(GridX, GridY, AgentsNum, WaitSteps, DispSteps, CSs, TestInput)->
%% 	{ok, P} = python:start(), % calling python 3 (python 2 throws some errors)
%% 	register(pyProcFil, P),
	P = whereis(pyProcFil),
	python:call(P, pathGenerator, register_handler, [self()]),
	python:cast(P,{GridX, GridY,AgentsNum, WaitSteps,DispSteps, CSs, "Filter", TestInput}),
	receive
        R->
			begin
%% 				python:stop(P),
				R
			end
    end.
	

%% testGenFilterTimes()->
%% 	GridX = 6,
%% 	GridY = 6,
%% 	AgentsNum = 3,
%% 	WaitSteps = 0,
%% 	DispSteps = 5,
%% 	InputNum = 2,
%% 	CSs = {"IN", {"Circle", 3}, {"Count", 2}},
%% 	FilterErl = fun(Input)  -> cshandler:evalCS(GridX, GridY, CSs, Input) end,
%% 	FilterPy  = fun(Input)  -> cshandler:pathFilterWithZ3(GridX, GridY,AgentsNum,WaitSteps, DispSteps, CSs, Input) end,
%% 	Time1 = erlang:timestamp(),
%% 	TestInputs = pathGenWithZ3(GridX, GridY, AgentsNum, WaitSteps, DispSteps, CSs, InputNum),
%% 	Time2 = erlang:timestamp(),
%% 	FilteredWithErl = [FilterErl(calculateAllPathsPoints(Inp, GridX, GridY))|| Inp<-TestInputs],
%% 	Time3 = erlang:timestamp(),
%% 	FilteredWithPy  = [FilterPy(calculateAllPathsPoints(Inp, GridX, GridY))|| Inp<-TestInputs],
%% 	Time4 = erlang:timestamp(),
%% 	GenTime  = timer:now_diff (Time2, Time1) div 1000000,
%% 	FErlTime = timer:now_diff (Time3, Time2) div 1000000,
%% 	FPyTime  = timer:now_diff (Time4, Time3) div 1000000,
%% 	io:fwrite("Test Inputs:~n~w~n",[TestInputs]),
%% 	io:fwrite("Filtered with Erlang:~n~w~n",[FilteredWithErl]),
%% 	io:fwrite("Filtered with Python:~n~w~n",[FilteredWithPy]),
%% 	io:fwrite("Generation time: ~w seconds.~n",[GenTime]),
%% 	io:fwrite("Filter Erl time: ~w seconds.~n",[FErlTime]),
%% 	io:fwrite("Filter Py  time: ~w seconds.~n",[FPyTime]).

%%=====================================================================================================
apropRun(GridSize, TurtlesNum, PathActionSteps, PathWaitSteps)->
	 FilterFunction = fun(TurtlesPaths)  -> checkMinDistanceOfAllPaths(calculateAllPathsPoints(TurtlesPaths, GridSize,GridSize),10) end,
	 Time1 = erlang:timestamp(),
	 ANS = counterexample(numtests(10000,aprop(GridSize, TurtlesNum, PathActionSteps, PathWaitSteps,FilterFunction)), [{with_info, true}]),
	 Time2 = erlang:timestamp(),
	 TimeDiff = timer:now_diff(Time2, Time1) div 1000000,
	 io:fwrite("Testing the property is done.~nIt took ~w seconds.~n",[TimeDiff]),
	 filelib:ensure_dir(filename:join(["time", "Time.txt"])), 
	 {ok,S} = file:open(filename:join(["time", "Time.txt"]), [write]),
	 io:format(S, "Test execution took ~w seconds.~n", [TimeDiff]),
	 ANS.

aprop(GridSize, TurtlesNumbers, PathActionSteps, PathWaitSteps, FilterFunction) ->
    MaxX = GridSize,
    MaxY = GridSize,
    noshrink(
	  ?FORALL(TurtlesPaths, turtlesPaths_gen_B(MaxX, MaxY, TurtlesNumbers, PathActionSteps, PathWaitSteps),
			?IMPLIES(FilterFunction(TurtlesPaths),true)
			%?IMPLIES(true,true)
	  )
	).

%%=====================================================================================================

%% @doc generates a list of turtlesPaths for each turtle, with method A, for the given number of turtles
%% @returns [ {turtleID, startingPointX, startingPointY, movementSequenceElements} ]
turtlesPaths_gen_A(MaxX, MaxY, TurtlesNumbers, PathActionSteps, PathWaitSteps) ->
    ?LET(Paths, [path_gen_A(MaxX, MaxY,PathActionSteps, PathWaitSteps) || _Index<-lists:seq(1, TurtlesNumbers) ],
         [ {Idx, StartX, StartY, Path} || {Idx, {StartX, StartY, Path}} <- lists:zip(lists:seq(1, length(Paths)), Paths) ]).

%% generates a random path by a triplet where the length of the movement actions is fixed
%% generated the path by starting from a random point and having random actions from action list
%% @returns {randomStartingPointX, randomStartingPointY, randomMovementSequenceElements}
path_gen_A(MaxX, MaxY, PathActionSteps, PathWaitSteps)->
	X = choose(0,MaxX),
	Y = choose(0,MaxY),
	
	Actions = [ elements([up, left, down, right]) || _Index<-lists:seq(1, PathActionSteps) ],
	WaitSteps = [ elements([nop]) || _Index<-lists:seq(1, PathWaitSteps) ],
	Path = Actions++WaitSteps,
	ShufflePath = [Z||{_,Z} <- lists:sort([ {rand:uniform(), P} || P <- Path])],    % shuffling the list
    {X, Y, ShufflePath}.
%%=====================================================================================================

%%=====================================================================================================

%% @doc generates a list of turtlesPaths for each turtle, with method B, for the given number of turtles
%% @returns [ {turtleID, startingPointX, startingPointY, movementSequenceElements} ]

turtlesPaths_gen_B(MaxX, MaxY, TurtlesNumbers, PathActionSteps, PathWaitSteps) ->
    ?LET(Paths, [path_gen_B(MaxX, MaxY,PathActionSteps, PathWaitSteps) || _Index<-lists:seq(1, TurtlesNumbers) ],
         [ {Idx, StartX, StartY, Path} || {Idx, {StartX, StartY, Path}} <- lists:zip(lists:seq(1, length(Paths)), Paths) ]
		).

%% generates a random path by a triplet where the length of the movement actions is fixed
%% generated the path by selecting a random starting and end points, and a random path between them
%% @returns {randomStartingPointX, randomStartingPointY, [movementSequenceElements]}
path_gen_B(MaxX, MaxY, PathActionSteps, PathWaitSteps)->
	?LET({StartX, StartY},
		 {choose(0,MaxX), choose(0,MaxY)},
		 ?LET({Xrand, Yrand},
			  {choose(0,2*PathActionSteps), choose(0,2*PathActionSteps)},
			  begin
				 OffsetX = Xrand - PathActionSteps,
				 OffsetY = Yrand - PathActionSteps,
				 % Finding the end point within a square, not circle
				 if 
					 StartX+OffsetX>MaxX -> EndX = MaxX;
					 StartX+OffsetX<0	 -> EndX = 0;
					 true 				 -> EndX = StartX+OffsetX
				 end,
				 
				 if 
					 StartY+OffsetY>MaxY -> EndY = MaxY;
					 StartY+OffsetY<0	 -> EndY = 0;
					 true 				 -> EndY = StartY+OffsetY
				 end,
				 
				 ?LET(RawRouteTemp, shuffle(findActions(StartX, StartY, EndX, EndY)),
					 begin
						 % in case, ending the route up to the circle borders 
						 % if the end point is out of the circle area
						 RawRoute = lists:sublist(RawRouteTemp, PathActionSteps),
					 
						 Diff = abs(length(RawRoute) - PathActionSteps),
						 Wiggling = [begin 
										  ?LET(Elem, elements([right, up]), 	
											   begin						 
													if
											 			(Elem == right) -> [right, left];
											 			true ->  [up, down]
										 			end
											   end)
									 end
									|| _<-lists:seq(1, Diff div 2) ],
						 WiggleActions  = ?LET(XXX, Wiggling,lists:append(XXX)),
						 AddRouteAction = ?LET( A,WiggleActions, 
												begin
													if 
												 		length(RawRoute)+length(A) == PathActionSteps -> [];
												 		true -> [elements([up, down, left,right])]
											 		end
													
												end),
						 WaitingActions = [ elements([nop]) || _Index<-lists:seq(1, PathWaitSteps) ],
						 Path = ?LET( {WA, ARA, WaitAc}, {WiggleActions,AddRouteAction,WaitingActions},
									  shuffle(RawRoute++WA++ARA++WaitAc)),
						 {StartX, StartY, Path}				 
				 	end)
				end)
		).
%%=====================================================================================================


printPointsAll([OneTurtle|[]])->
	{ok,PF} = file:open("gen_deltaXY.txt", [append]),
	io:format(PF, "~w\t~w~n", [findMinMaxDif(OneTurtle,x), findMinMaxDif(OneTurtle, y)]),
	file:close(PF);
%	printPointOne(OneTurtle);
%% 	io:fwrite("~n"),
%% 	io:fwrite("############# Range ############~n"),
%% 	io:fwrite("(~w,~w)~n",[findMinMaxDif(OneTurtle,x), findMinMaxDif(OneTurtle, y)]),
%% 	io:fwrite("################################~n");
printPointsAll([OneTurtle|Others])->
	{ok,PF} = file:open("gen_deltaXY.txt", [append]),
	io:format(PF, "~w\t~w~n", [findMinMaxDif(OneTurtle,x), findMinMaxDif(OneTurtle, y)]),
	file:close(PF),
	%io:fwrite("point One is printing: ~w~n",[OneTurtle]),
%	printPointOne(OneTurtle),
%% 	io:fwrite("~n"),
%% 	io:fwrite("############# Range ############~n"),
%% 	io:fwrite("(~w,~w)~n",[findMinMaxDif(OneTurtle,x), findMinMaxDif(OneTurtle, y)]),
%% 	io:fwrite("################################~n"),
	printPointsAll(Others).

printPointOne([	#{x := X,y := Y}|[]])->
	{ok,PF} = file:open("gen_toDraw.txt", [append]),
	io:format(PF, "~w\t~w~n", [X, Y]),
	io:fwrite("(~w,~w),",[X,Y]),
	file:close(PF);
printPointOne([	#{x := X,y := Y}|Next])->
	{ok,PF} = file:open("gen_toDraw.txt", [append]),
	io:format(PF, "~w\t~w~n", [X, Y]),
	io:fwrite("(~w,~w),",[X,Y]),
	file:close(PF),
	printPointOne(Next).

findMinMaxDif(Points, Var)->
	case Var of
		x ->
			Xs = [X || #{x := X,y := _Y}<-Points],
			MinX = lists:min(Xs),
			MaxX = lists:max(Xs),
			Ans = MaxX-MinX;
		y ->
			Ys = [Y || #{x := _X,y := Y}<-Points],
			MinY = lists:min(Ys),
			MaxY = lists:max(Ys),
			Ans = MaxY-MinY	
	end,
	Ans.
	

propTestRun(GridSize, TurtlesNum, PathActionSteps, PathWaitSteps)->
	counterexample(numtests(1,propTest(GridSize, TurtlesNum, PathActionSteps, PathWaitSteps)), [{with_info, true}]).

propTest(GridSize, TurtlesNum, PathActionSteps, PathWaitSteps) ->
    MaxX = GridSize,
    MaxY = GridSize,
    noshrink(?FORALL(TurtlesPaths, turtlesPaths_gen_A(MaxX, MaxY, TurtlesNum, PathActionSteps, PathWaitSteps),
			?IMPLIES(true,
					 begin
		                Trace = turtlesworld:run(TurtlesPaths, MaxX, MaxY),
						?WHENFAIL(begin
								  	%io:fwrite("paths: ~w~n",[TurtlesPaths]),
									Points = calculateAllPathsPoints(TurtlesPaths, MaxX, MaxY),
									%io:fwrite("points: ~w~n",[Points])
%% 									filelib:ensure_dir("points.txt"), 
%% 									{ok,PF} = file:open("points.txt", [write]),
%% 									io:format(PF, "~s", [""]),
%% 									io:fwrite("points: ~n"),
									filelib:ensure_dir("gen_deltaXY.txt"), 
									{ok,PF} = file:open("gen_deltaXY.txt", [write]),
									io:format(PF, "~s", [""]),
									printPointsAll(Points),
									io:fwrite("Is Filtered to test?: ~n"),
									RES = existsCommonInAllPaths(calculateAllPathsPoints(TurtlesPaths, GridSize,GridSize)),
									if 
										RES	-> io:fwrite("YES: ~n");
										true-> io:fwrite("No: ~n")
									end
										
								  end,
		                          begin
		                              Result = false,
		                              user_info(trace_length,
		                                        fun(undefined) when not Result -> [{length(TurtlesPaths),length(Trace)}];
		                                           (V) when not Result -> V ++ [{length(TurtlesPaths),length(Trace)}];
		                                           (V) -> V
		                                        end, 
												Result)
		
		                          end)
		            end)
			)%.
	).


%%=====================================================================================================
%% @doc finds the needed horizental and vertical actions to go from (StartX1,StartY1) to (StartX2,StartY2)
%% @returns a list of moves from the movement list {left, right, up, down}
findActions(X1, Y1, X2, Y2) ->
	Xdif = X2-X1,
	Ydif = Y2-Y1,
	if 
		Xdif>0 -> HActions = [ right || _<-lists:seq(1, Xdif)  ];
		Xdif<0 -> HActions = [ left  || _<-lists:seq(1, -Xdif) ];
		true   -> HActions =[]
	end,
	
	if 
		Ydif>0 -> VActions = [ up    || _<-lists:seq(1, Ydif)  ];
		Ydif<0 -> VActions = [ down  || _<-lists:seq(1, -Ydif) ];
		true   -> VActions =[]
	end,
	
	HActions++VActions.
%%=====================================================================================================

%%=====================================================================================================

%% @doc This method takes a list of records containing test execution information
%% 		and cleans the items in the records that are not of our interest and
%% 		collects relevant results in the record items.
%% @param TestExecInfo is the test execution informations, as a list of records.
%%		  Each record in the list has the following format:
%%			#{
%%	  			aggregated_data,
%%	  			measurements,
%%	  			reason,
%%	  			result,
%%	  			statistics,
%%	  			user_info
%%	 		}
%%		  Each of these items has their own type.
%%		  Among these information, the item 'statistics' is of more interests to us 
%%		  that has a record type with the follwing structure:
%%			#{
%%	  			discards,				----> an integer, as the number of discarded test inputs by filtering
%%	  			failed_shrinksteps,   	----> an integer, as the number of failed shrinking steps
%%	  			numtests,				----> an integer, as the number of executed tests to reach a pass/fail conlusion
%%	  			outcome,				----> a boolean, as if the test was successful or not
%%	  			shrinksteps				----> an integer, as the number of successful shrinking steps to reach the most shrunk test case
%%											  For successful tests, we do not have shrinking.
%%	 		}
%% @returns a record with the following format
%%			#{
%%				[discards],
%%	  			[ansNumTests],			
%%	  			[ansFailedShrinkSteps],
%%	  			[ansShrinkSteps]
%%	 		}
%%			Each item in this record is a list that collects all of the corresponding items in the input records.


cleanAndCombineInfo_PropCollision(TestExecInfo)->
	cleanAndCombineInfo_PropCollision(TestExecInfo, #{ansDiscards => [], ansNumTests => [], ansFailedShrinkSteps =>[], ansShrinkSteps=>[]}).

cleanAndCombineInfo_PropCollision([] , AnsTemp) ->
	AnsTemp;

cleanAndCombineInfo_PropCollision([FirstPart|Other],AnsTemp) ->
	#{
	  ansDiscards := AnsDiscards,
	  ansNumTests := AnsNumTests, 
	  ansFailedShrinkSteps := AnsFailedShrinkSteps, 
	  ansShrinkSteps := AnsShrinkSteps
	 } = AnsTemp,

	#{
	  statistics := Statistics
	 } = FirstPart,
	
	#{
	  discards := Discards,
	  failed_shrinksteps := Failed_shrinksteps,
	  numtests := NumTests,
	  shrinksteps:= ShrinkSteps
	 } = Statistics,
	
	UpdateDiscards = AnsDiscards ++ [Discards],
	UpdatedFailedShrinkSteps = AnsFailedShrinkSteps ++ [Failed_shrinksteps],
	UpdateNumTests = AnsNumTests ++ [NumTests],
	UpdatedShrinkSteps = AnsShrinkSteps ++ [ShrinkSteps],
	 
	UpdatedAnsTemp = #{
					   ansDiscards => UpdateDiscards,
					   ansNumTests => UpdateNumTests, 
					   ansFailedShrinkSteps=>UpdatedFailedShrinkSteps, 
					   ansShrinkSteps=>UpdatedShrinkSteps
					  },
	
	cleanAndCombineInfo_PropCollision(Other, UpdatedAnsTemp).

%%====================================================================================================

%%=====================================================================================================

%% @doc This method checks that for all paths (lists of locations) there exists any member in common between two of the paths.
%% @param list of paths (lists of locations). Each location is a record having the format of {x,y}
%% @returns true if at least one common member exists bertween two of the paths, false otherwise.

existsCommonInAllPaths([_FirstPathPoints|[]])-> 
	false;

existsCommonInAllPaths([FirstPathPoints|OtherPathsPoints])-> 
	Bool1 = existsCommonInAllPaths(FirstPathPoints,OtherPathsPoints),
	if Bool1 ->
		   true;
	   true ->
		   existsCommonInAllPaths(OtherPathsPoints)
	end.

existsCommonInAllPaths(PathPoints,[NextPoints|[]])-> 
	existsCommonInTwoPaths(PathPoints,NextPoints);

existsCommonInAllPaths(PathPoints,[NextPoints|OtherNextPoints])->
	Bool = existsCommonInTwoPaths(PathPoints,NextPoints),
	if Bool ->
		   true;
	   true->
		   existsCommonInAllPaths(PathPoints, OtherNextPoints)
	end.

%%=====================================================================================================

%%=====================================================================================================

%% @doc This method checks that the two lists of locations have any member in common.
%% @param first and second parameters are lists of locations. Each location is a record having the format of {x,y}
%% @returns true if at least one common member exists, false otherwise.

existsCommonInTwoPaths([], _List2)->
	false;

existsCommonInTwoPaths(_List1, [])-> 
	false;

existsCommonInTwoPaths([First|Others], List2)->
	{X,Y} = First,
	Predicate = fun(M) -> {X2,Y2} =M, (X2==X) and (Y2==Y) end,
	Bool = lists:any(Predicate, List2),
	if 
		Bool -> true;
		true -> existsCommonInTwoPaths(Others,List2)
	end.

%%=====================================================================================================

%%=====================================================================================================

%% @doc This method checks that if, among all paths, there is two paths that the pair-wise distance of them is less than 
%%		a certain value at some time 
%% @param AllPathPoints are the list of all paths' locations
%% @param Distance is the distance value that the function checks based on that.
%% @returns true, if among all paths, there is at least two paths that their pair-wise distance is less than 
%%		    a certain value at some point , false otherwise 

checkMinDistanceOfAllPaths([_FirstPathPoints|[]], _Distance)->  
	false;

checkMinDistanceOfAllPaths([FirstPathPoints|OtherPathsPoints], Distance)-> 
	Bool1 = checkMinDistanceOfAllPaths(FirstPathPoints,OtherPathsPoints, Distance),
	if Bool1 ->
		   true;
	   true ->
		   checkMinDistanceOfAllPaths(OtherPathsPoints, Distance)
	end.

%% @param PathPoints is the list of one path locations
%% @param NextPoints are the list of paths' locations
%% @param Distance is the distance that the function checks based on that.

checkMinDistanceOfAllPaths(PathPoints,[NextPoints|[]], Distance)-> 
	checkMinDistanceOfTwoPaths(PathPoints,NextPoints, Distance);

checkMinDistanceOfAllPaths(PathPoints,[NextPoints|OtherNextPoints], Distance )->
	Bool = checkMinDistanceOfTwoPaths(PathPoints,NextPoints, Distance),
	if Bool ->
		   true;
	   true->
		   checkMinDistanceOfAllPaths(PathPoints, OtherNextPoints, Distance)
	end.

%%=====================================================================================================

%%=====================================================================================================

%% @doc This method checks that if the pair-wise distance of the two given lists of locations is less than the given distance at some time
%% @param first and second parameters are lists of locations.
%% @param Distance is the distance that the function checks based on that.
%% @returns true if the pair-wise distance of the two given lists of locations is less than the given distance at some time, false otherwise 

checkMinDistanceOfTwoPaths([],_List2,_Distance)->
	false;

checkMinDistanceOfTwoPaths(_List1,[],_Distance)->
	false;

checkMinDistanceOfTwoPaths([First1|Others1], [First2|Others2], Distance)->
	{X,Y}   = First1,
	{X2,Y2} = First2,
	
	CheckFirsts = math:sqrt( math:pow(X-X2, 2)+ math:pow(Y-Y2, 2)) =< Distance,
	%AreFirstsClose = (abs(X-X2)=<Distance) and (abs(Y-Y2)=<Distance) ,
	if 
		CheckFirsts ->
		   true;
		true ->		
			if
				(Others1==[]) and (Others2==[]) ->
					false;
				Others1==[] ->
					checkMinDistanceOfTwoPaths([First1],Others2,Distance);
				Others2==[]->
					checkMinDistanceOfTwoPaths(Others1,[First2],Distance);
				true->
					checkMinDistanceOfTwoPaths(Others1,Others2,Distance)
									
			end
	end.

%%=====================================================================================================

%%=====================================================================================================

%% @doc This method calculated the locations that would be traversed by all of the TurtlesPaths.
%% @precondition input is not empty
%% @param TurtlesPaths is a list of records having the format {Id, StartX, StartY, Path}
%% @returns a list of list of caluculated locations that would be traversed by all of the TurtlesPaths.

calculateAllPathsPoints([TurtlePath|[]], GridX, GridY)->
	Points = calculatePathPoints(TurtlePath, GridX, GridY),
	[Points];

calculateAllPathsPoints([TurtlePath|OtherTurtlesPaths], GridX, GridY)->
	Points = calculatePathPoints(TurtlePath, GridX, GridY),
	OtherPoints = calculateAllPathsPoints(OtherTurtlesPaths, GridX, GridY),
	[Points]++OtherPoints.

calculatePathPoints({_Idx, StartX, StartY, Path}, GridX, GridY)->
	FirstPoint = {StartX,StartY},
	[FirstPoint]++findNextPoints(StartX,StartY,Path, GridX, GridY,[]).

%%=====================================================================================================	

%%=====================================================================================================

%% @doc This method calculated the points that would be traversed by starting from one point and having a sequence of actions.
%% @param StartX is the x coordinate of starting point
%% @param StartY is the y coordinate of starting point
%% @param NextDirection is the list (as sequece) of directions of the upcomming moves
%% @param TraversedPoints is the caulated points up to certain level
%% @returns a list of the caluculated points that would be traversed by starting from the given point and the a sequence of actions.

findNextPoints(_StartX,_StartY,[], _GridX, _GridY,_TraversedPoints)->
	[];

findNextPoints(StartX,StartY,[NextDirection|[]], GridX, GridY,TraversedPoints)->
	case NextDirection of
		up    -> if 
					 (StartY < GridY) 	-> NextPoint = {StartX,StartY+1}; %#{x=>StartX,y=>StartY+1};
				 	 true				-> NextPoint = {StartX,StartY}
				 end;
		down  -> if 
					 (StartY > 0) 		-> NextPoint = {StartX,StartY-1};
					 true				-> NextPoint = {StartX,StartY}
				 end;
		left  -> if 
					 (StartX>0) 		-> NextPoint = {StartX-1,StartY};
					 true				-> NextPoint = {StartX,StartY}
				 end;
		right -> if 
					 (StartX<GridX)		-> NextPoint = {StartX+1,StartY} ;
					 true				-> NextPoint = {StartX,StartY}
				 end;
		nop   							-> NextPoint = {StartX,StartY}
	end,
	TraversedPoints++[NextPoint];

findNextPoints(StartX,StartY,[NextDirection|OtherDirections], GridX, GridY,TraversedPoints)->
	case NextDirection of
		up    -> if 
					 (StartY < GridY) 	-> NextPoint = {StartX,StartY+1}; %#{x=>StartX,y=>StartY+1};
				 	 true				-> NextPoint = {StartX,StartY}
				 end;
		down  -> if 
					 (StartY > 0) 		-> NextPoint = {StartX,StartY-1};
					 true				-> NextPoint = {StartX,StartY}
				 end;
		left  -> if 
					 (StartX>0) 		-> NextPoint = {StartX-1,StartY};
					 true				-> NextPoint = {StartX,StartY}
				 end;
		right -> if 
					 (StartX<GridX)		-> NextPoint = {StartX+1,StartY} ;
					 true				-> NextPoint = {StartX,StartY}
				 end;
		nop   							-> NextPoint = {StartX,StartY}
	end,
	
	{NextX, NextY} = NextPoint,
	UpdatedPoints = TraversedPoints++[NextPoint],
	findNextPoints(NextX, NextY,OtherDirections, GridX, GridY,UpdatedPoints).

%%=====================================================================================================

