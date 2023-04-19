-module(qcFilterPerformance).
-include_lib("eqc/include/eqc.hrl").	% this library needs installing quickcheck
-compile([export_all, nowarn_export_all]).

% calculating the performance of QC for test input generation in our experiment II

experiment2()->	
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

%% 	calcErlangPerformance(20, 20, 20, 20, 1, CS, "BadData", 1, 1 ),
	[calcErlangPerformance(GridSize, AgentsNum, WaitSteps, DispSteps, InputNum, CS, CS_folderName, RepeatExp, TimeOutSec )
	 ||  GridSize<-GridSizes,AgentsNum<- AgentsNums, DispSteps<-DispStepss ],
	
	io:fwrite("Calculation is Done!").
	
calcErlangPerformance(GridSize, AgentsNum, WaitSteps, DispSteps, InputNum, CS, CS_folderName, RepeatExp, TimeOutSec)->
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

	Results = [forceGetFilteredInputs(GridSize, GridSize, AgentsNum, WaitSteps, DispSteps, CS, InputNum, "GenB", TimeOutMilSec) || _I<-lists:seq(1, RepeatExp)],
	FileNameTimes  = filename:join([FolderNameTimes,  ExpInfo++"-Fil-Erl-GenB.txt"]),
	FileNameInputs = filename:join([FolderNameInputs, ExpInfo++"-Fil-Erl-GenB.txt"]),
	filelib:ensure_dir(FileNameTimes), 
	filelib:ensure_dir(FileNameInputs), 
	
	saveTimesToFile( Results, FileNameTimes),
	saveInputsToFile(Results, FileNameInputs),
	io:fwrite("~nFiltering with erlang code-GenB is done and saved in a file. ~n~n"),
	timer:sleep(1000),
	
	io:fwrite("~nFinished Data Generation for "++ ExpInfo ++ "~n~n").

forceGetFilteredInputs(GridSize, GridSize, AgentsNum, WaitSteps, DispSteps, CS, InputNum, GenType, MaxTimeMilliSec)->
	Time1 = erlang:timestamp(),
	Pid = spawn(qcFilterPerformance, returnFilteredInputs, [self(), GridSize, GridSize, AgentsNum, WaitSteps, DispSteps, CS, InputNum, GenType, []]),        
	receive
		Inputs->
			Time2 = erlang:timestamp(),
			DifTime = timer:now_diff (Time2, Time1) div 1000, % milli seconds
			{Inputs, DifTime}
	after MaxTimeMilliSec ->
		exit(Pid, kill),
		io:format("~n~nTime out!~n~n"),
		{timeout, MaxTimeMilliSec} %return timeout after no result for inputNum test inputs	
	end.

returnFilteredInputs(Pid, GridSize, GridSize, AgentsNum, WaitSteps, DispSteps, CS, InputNum, GenType, AnsInput)->
	Pid ! getFilteredInputs(GridSize, GridSize, AgentsNum, WaitSteps, DispSteps, CS, InputNum, GenType, AnsInput).

getFilteredInputs(GridSize, GridSize, AgentsNum, WaitSteps, DispSteps, CS, InputNum, GenType, AnsInput)->
	RequiredNewCases = InputNum - length(AnsInput),
	if
		RequiredNewCases > 0 ->
			begin
				{_,NewInputs} = eqc_suite:random(numtests(RequiredNewCases,prop2(GridSize,AgentsNum, DispSteps, WaitSteps, CS, GenType ))),
				CleanedInputs = [Inp||[Inp|[]]<-NewInputs],
				getFilteredInputs(GridSize, GridSize, AgentsNum, WaitSteps, DispSteps, CS, InputNum, GenType, AnsInput++CleanedInputs)
			end;
		true->
			AnsInput
	end.

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

saveInputSetsToFile([OneSetOfInputs|[]], MyFile, SetNum)->
	io:format(MyFile, "Repeat Index:~w~n~n~n",[SetNum]),
	if 
		OneSetOfInputs==timeout-> io:format(MyFile, "Time-out~n~n~n",[]);
	 	true-> begin
			   	   saveInputsToFile(OneSetOfInputs, MyFile, 1)
			   end
	 end;

saveInputSetsToFile([OneSetOfInputs|OtherSets], MyFile, SetNum)->
	io:format(MyFile, "Repeat Index:~w~n~n~n",[SetNum]),
	if 
		OneSetOfInputs==timeout-> io:format(MyFile, "Time-out~n~n~n",[]);
	 	true-> begin
			   	   saveInputsToFile(OneSetOfInputs, MyFile, 1)
			   end
	 end,
	saveInputSetsToFile(OtherSets, MyFile, SetNum+1).

% we need at least one moving step
saveInputsToFile( [OneInput|[]], MyFile, TestInputNum)->
	io:format(MyFile, "Test input:~w~n",[TestInputNum]),
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

prop2(GridSize, TurtlesNumbers, PathActionSteps, PathWaitSteps, CS, GenType) ->
    MaxX = GridSize,
    MaxY = GridSize,
	FilterFunction = fun(TurtlesPaths) -> cshandler:evalCS(GridSize, GridSize, CS, TurtlesPaths ) end,
	
	noshrink(
	  ?FORALL(TurtlesPaths, 
			  begin
				  	if 
						GenType == "GenA" -> turtle_nop:turtlesPaths_gen_A(MaxX, MaxY, TurtlesNumbers, PathActionSteps, PathWaitSteps) ;
						GenType == "GenB" -> turtle_nop:turtlesPaths_gen_B(MaxX, MaxY, TurtlesNumbers, PathActionSteps, PathWaitSteps)
					end
			  end,
			  ?IMPLIES(FilterFunction( turtle_nop:calculateAllPathsPoints (TurtlesPaths, MaxX, MaxY) ),
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


