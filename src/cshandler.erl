
-module(cshandler).
-compile([export_all, nowarn_export_all]).


%% @doc evaluates if the constraint is satisfied for the paths in the grid
evalCS(GridX, GridY, CSs, Paths)-> % the number of agents and the time of movement is detectable from 'Paths'
	case tuple_size(CSs) of
		2 ->
			begin
				{KeyWord, L1} = CSs,
				case KeyWord of
					"NOT" 	-> not evalCS(GridX, GridY,L1, Paths);
					_		-> io:fwrite("Parsing Error - (~w,_) is invalid for Constraint type.~n ", [KeyWord])
				end
			end;
		3 ->
			begin
				{KeyWord, L1, L2} = CSs,
				case KeyWord of
					"OR" 	-> evalCS(GridX, GridY,L1, Paths) orelse  evalCS(GridX, GridY,L2, Paths);
					"AND"	-> evalCS(GridX, GridY,L1, Paths) andalso evalCS(GridX, GridY,L2, Paths);
					"IN" 	-> evalCondition(GridX, GridY, L1, L2, Paths);
					_		-> io:fwrite("Parsing Error - (~w,_,_) is invalid for Constraint type.~n ", [KeyWord])
				end
			end;
		_->	io:fwrite("Parsing Error - ~w is an invalid Constraint.~n ", [CSs])
	end.

%% @doc checks if the condition in the area is satisfied for the paths in the grid
evalCondition(GridX, GridY, Area, Condition, Paths)->
	case tuple_size(Area) of
		2-> begin
				{AreaType, AreaSize} = Area,
				AreaCenters = [{I/2,J/2} ||I<-lists:seq(0,2*GridX), J<-lists:seq(0,2*GridY)],
				ShuffledCenteres = [X||{_,X} <- lists:sort([ {random:uniform(), N} || N <- AreaCenters])],
	
				case AreaType of
					"Circle"-> evalCircleInstancesCondition(AreaSize,ShuffledCenteres, Condition, Paths);
					"Square"-> evalSquareInstancesCondition(AreaSize,ShuffledCenteres, Condition, Paths);
					_		-> io:fwrite("Parsing Error - ~w is an invalid area type.~n ", [AreaType])	
				end
			end;

		_-> begin
				io:fwrite("Parsing Error - ~w is an invalid condition area.~n ", [Area])
			end
	end.

%%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%%++++++++++++++++++++++++++++++++++++++CIRCLE AREA++++++++++++++++++++++++++++++++++++++++++++++++
%%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%% @doc checks if the condition in a circle with the radius and one of the centers is satisfied for the paths
evalCircleInstancesCondition(AreaSize,ShuffledCenteres, Condition, Paths)->
	case ShuffledCenteres of
		[]->false;
		[Center|Tail] -> 
			begin
				Ans = evalOneCircleCondition(AreaSize, Center, Condition, Paths),
				if 
					Ans==true 	-> true;
					true		-> evalCircleInstancesCondition(AreaSize, Tail, Condition, Paths)
				end
			end
	end.

%% @doc checks if the condition in a circle with the radius and center is satisfied for the paths
evalOneCircleCondition(AreaSize,Center, Condition, Paths)->
	case tuple_size(Condition) of
		2->
			begin
				{KeyWord, L1} = Condition,
				case KeyWord of
					"Count" -> checkCircleCount(AreaSize,Center,L1,Paths);
					"Not" 	-> not evalOneCircleCondition(AreaSize,Center,L1,Paths);
					_		-> io:fwrite("Parsing Error - (~w,_) is invalid for condition type.~n ", [KeyWord])	
				end
			end;
		3->
			begin
				{KeyWord, L1, L2} = Condition,
				case KeyWord of
					"Intersection"	-> checkCircleIntersection(AreaSize,Center,L1,L2,Paths);
					"And" 			-> evalOneCircleCondition(AreaSize,Center,L1, Paths) 
										andalso evalOneCircleCondition(AreaSize,Center,L2, Paths);
					"Or" 			-> evalOneCircleCondition(AreaSize,Center,L1, Paths) 
										orelse  evalOneCircleCondition(AreaSize,Center, L2, Paths);
					_				-> io:fwrite("Parsing Error - (~w,_,_) is invalid for condition type.~n ", [KeyWord])	
				end
			end;
		
		_->	io:fwrite("Parsing Error - ~w is an invalid condition.~n ", [Condition])
	end.	

%% @doc checks if at least the given number of agents exists in a circle with the radius and center for the paths
checkCircleCount(Radius, Center, Count, Paths)->
	%MyPaths = samplePath(),  % for testing
	AgentNum = length(Paths),
	Time = length(lists:nth(1,Paths)), % assuming all of the paths have the same length (moving the same time steps)
	PointsSet = [ [lists:nth(J, lists:nth(I,Paths)) || I <- lists:seq(1,AgentNum) ] || J <- lists:seq(1,Time)], 
	% the member 'i' of PoinsSet is the list of locations of all agents in time 'i' 
	lists:any(fun(X)->X end, [checkMinCountInCircle(Points,Center, Radius, Count)||Points<-PointsSet]).

checkMinCountInCircle(_Points,_Center, _Radius, 0) -> true;
checkMinCountInCircle([],_Center, _Radius, _Count) -> false;
checkMinCountInCircle([Point|Tail],Center,Radius,Count) -> 
	{Px,Py} = Point,
	{Cx,Cy} = Center,
	IsIn = math:sqrt( math:pow(Px-Cx, 2) + math:pow(Py-Cy, 2)) =< Radius,
	if
		IsIn==true 	-> checkMinCountInCircle(Tail,Center,Radius,Count-1);
		true 		-> checkMinCountInCircle(Tail,Center,Radius,Count)
	end.
		
%% @doc checks if at least the given number of intersections with the given degree
%% 		exists in a circle with the given radius and center for the paths		
checkCircleIntersection(Radius, Center, Number, Degree, Paths)->
	PathsUniquePoints = [sets:to_list(sets:from_list(Path))|| Path<-Paths], % removing not unique points of the paths
	FlatPoints = lists:append(PathsUniquePoints),
	MapPoints  = lists:foldl(fun(X,Sum)-> maps:put(X, maps:get(X, Sum, 0)+1, Sum) end, #{}, FlatPoints),
	SatisfyDegreePoints = maps:filter(fun(_K,V)->V>=Degree end, MapPoints), % finding all intersection points including at least 'Degree' agents
	%io:fwrite("Satisfied Points:~w~n", [maps:keys(SatisfyDegreePoints)]),
	checkMinCountInCircle(maps:keys(SatisfyDegreePoints), Center, Radius, Number). % checking the intersections close to the considering center

%%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%%++++++++++++++++++++++++++++++++++++++SQUARE AREA++++++++++++++++++++++++++++++++++++++++++++++++
%%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%% @doc checks if the condition in a square with the side length and one of the centers is satisfied for the paths
evalSquareInstancesCondition(AreaSize,ShuffledCenteres, Condition, Paths)->
	case ShuffledCenteres of
		[]->false;
		[Center|Tail] -> 
			begin
				Ans = evalOneSquareCondition(AreaSize, Center, Condition, Paths),
				if 
					Ans==true 	-> true;
					true		-> evalSquareInstancesCondition(AreaSize, Tail, Condition, Paths)
				end
			end
	end.

%% @doc checks if the condition in a square with the given side length and center is satisfied for the paths
evalOneSquareCondition(AreaSize,Center, Condition, Paths)->
	case tuple_size(Condition) of
		2->
			begin
				{KeyWord, L1} = Condition,
				case KeyWord of
					"Count" -> checkSquareCount(AreaSize,Center,L1,Paths);
					"Not" 	-> not evalOneSquareCondition(AreaSize,Center,L1,Paths)
				end
			end;
		3->
			begin
				{KeyWord, L1, L2} = Condition,
				case KeyWord of
					"Intersection"	-> checkSquareIntersection(AreaSize,Center,L1,L2,Paths);
					"And" 			-> evalOneSquareCondition(AreaSize,Center,L1, Paths) 
										andalso evalOneSquareCondition(AreaSize,Center,L2, Paths);
					"Or" 			-> evalOneSquareCondition(AreaSize,Center,L1, Paths) 
										orelse  evalOneSquareCondition(AreaSize,Center, L2, Paths)
				end
			end;
		_->	io:fwrite("Parsing Error - ~w is an invalid condition.~n ", [Condition])
	end.	

%% @doc checks if at least the given number of agents exists in a square with the given side length and center for the paths
checkSquareCount(SideLength, Center, Count, Paths)->
	AgentNum = length(Paths),
	Time = length(lists:nth(1,Paths)), % assuming all of the paths have the same length (moving the same time steps)
	PointsSet = [ [lists:nth(J, lists:nth(I,Paths)) || I <- lists:seq(1,AgentNum) ] || J <- lists:seq(1,Time)],
	lists:any(fun(X)->X end, [checkMinCountInSquare(Points,Center, SideLength, Count)||Points<-PointsSet]).

checkMinCountInSquare(_Points,_Center, _SideLength, 0) -> true;
checkMinCountInSquare([],_Center, _SideLength, _Count) -> false;
checkMinCountInSquare([Point|Tail],Center,SideLength,Count) -> 
	{Px,Py} = Point,
	{Cx,Cy} = Center,
	IsIn = (abs(Px-Cx)=<(SideLength/2)) andalso (abs(Py-Cy)=<(SideLength/2)),
	if
		IsIn==true 	-> checkMinCountInSquare(Tail,Center,SideLength,Count-1);
		true 		-> checkMinCountInSquare(Tail,Center,SideLength,Count)
	end.
		

%% @doc checks if at least the given number of intersections with the given degree
%% 		exists in a square with the given side length and center for the paths	
checkSquareIntersection(SideLength, Center, Number, Degree, Paths)->
	PathsUniquePoints = [sets:to_list(sets:from_list(Path))|| Path<-Paths], % removing not unique points of the paths
	FlatPoints = lists:append(PathsUniquePoints),
	MapPoints  = lists:foldl(fun(X,Sum)-> maps:put(X, maps:get(X, Sum, 0)+1, Sum) end, #{}, FlatPoints),
	SatisfyDegreePoints = maps:filter(fun(_K,V)->V>=Degree end, MapPoints), % finding all intersection points including at least 'Degree' agents
	%io:fwrite("Satisfied Points:~w~n", [maps:keys(SatisfyDegreePoints)]),
	checkMinCountInSquare(maps:keys(SatisfyDegreePoints), Center, SideLength, Number). % checking the intersections close to the considering center


%%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%%++++++++++++++++++++++++++++++++++++++TEST CODE++++++++++++++++++++++++++++++++++++++++++++++++++
%%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

paperEx1()->
	CSs = {"IN", {"Square", 2}, {"Count", 4}},
	evalCS(6, 6, CSs, samplePath()).

paperEx2()->
	CSs = {"IN", {"Circle", 1}, {"Intersection", 1,2}},
	evalCS(6, 6, CSs, samplePath()).

paperEx3()->
	CSs = {"IN", {"Square", 3}, {"And", {"Intersection", 1,2}, {"Count", 3}} },
	evalCS(6, 6, CSs, samplePath()).

samplePath()->
	P1 = [{1,5}, { 0,5}, {0,4}, {0,3}, {1,3}, {1,2}, {1,1}],
	P2 = [{3,5}, { 3,6}, {4,6}, {5,6}, {5,5}, {5,4}, {6,4}],
	P3 = [{3,4}, { 4,4}, {4,3}, {4,2}, {4,1}, {5,1}, {5,0}],
	P4 = [{5,2}, { 4,2}, {3,2}, {3,1}, {2,1}, {2,2}, {1,2}],
	[P1]++[P2]++[P3]++[P4].


paperEx4()->
	CSs = {"IN", {"Circle", 1}, {"Count", 2}},
	evalCS(20, 20, CSs, samplePath2()).

samplePath2()->
	 P1 = [{7,12}, {7,12}, {7,12}, {6,12}, {6,12}, {6,12}, {5,12}, {4,12}, {3,12}, {2,12}, {2,12}],
	 P2 = [{17,1}, {16,1}, {16,1}, {15,1}, {14,1}, {13,1}, {13,1}, {13,1}, {13,1}, {12,1}, {12,1}],
	 P3 = [{10,18},{10,18},{11,18},{11,18},{11,17},{11,16},{11,15},{11,15},{11,15},{11,15},{11,14}],
	 P4 = [{5,11}, {5,11}, {5,11}, {5,11}, {5,11}, {5,12}, {5,13}, {5,14}, {5,14}, {5,15}, {5,16}],
	 P5 = [{11,8}, {11,9}, {11,9}, {12,9}, {12,9}, {12,9}, {12,9}, {13,9}, {13,9}, {13,10},{14,10}],
	 [P1]++[P2]++[P3]++[P4]++[P5].

	 

test2Z3()->
	GridX = 15,
    GridY = 15,
    AgentsNum = 2,
    WaitSteps = 0,
    DispSteps = 2,
	%InputNum = 5,
	CSs = {"IN", {"Circle", 1}, {"Count", 2}},
	TestInput = [[{0,3},{0,4},{0,4}],[{10,15},{9,15},{9,14}]],
	FilterFunction2 = fun(TurtlesPaths) -> pathFilterWithZ3(GridX, GridY, AgentsNum, WaitSteps, DispSteps, CSs, TurtlesPaths) end,
    
	FilterFunction2(TestInput).
%%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
testZ3Filter()->
	GridX = 7,
    GridY = 7,
    AgentsNum = 4,
    WaitSteps = 0,
    DispSteps = 5,
	%InputNum = 5,
	CSs = {"IN", {"Circle", 1}, {"Count", 2}},
	TestInput = samplePath(),
	FilterFunction2 = fun(TurtlesPaths) -> pathFilterWithZ3(GridX, GridY, AgentsNum, WaitSteps, DispSteps, CSs, TurtlesPaths) end,
    
	FilterFunction2(TestInput).
	% pathFilterWithZ3(GridX, GridY, AgentsNum, WaitSteps, DispSteps, CSs, TestInput).
	% Ans = pathFilterWithZ3(7, 7, 4, 0, 6, CSs, samplePath()),
	% if
	% 	(Ans==true) -> io:fwrite("2: Is Satisfied.~n");
	% 	(Ans==false)-> io:fwrite("2: Is Not Satisfied.~n")
	% end,
	% io:fwrite("Finished!").

pathFilterWithZ3(GridX, GridY, AgentsNum, WaitSteps, DispSteps, CSs, TestInput)->
	{ok, P} = python:start(), % calling python 3 (python 2 throws some errors)
	python:call(P, pathGenerator, register_handler, [self()]),
	python:cast(P,{GridX, GridY,AgentsNum, WaitSteps,DispSteps, CSs, "Filter", TestInput}),
	receive
        R->R
			% begin
            %     %[io:fwrite("Set of Paths:~n~w~n",[Inp]) || Inp<-R],
            %     if
            %         (R==true) -> io:fwrite("1: Is Satisfied.~n");
            %         (R==false)-> io:fwrite("1: Is Not Satisfied.~n")
            %     end,
            %     io:fwrite("Finished!"),
            %     R
            % end
    end.

% performance tip: Check the whole constraint and if there are requests for 'intersection'
% ,or in anyway, calculate them once and save that somewhere and use them in the code 