%% @author sinent
%% @doc @todo Add description to filehelper.


-module(filehelper).
-export([writeFileResults_exp1Format/5]).

%%=====================================================================================================

%% @doc This method writes one aspect of the test execution results to the file.
%%		They will be written in a format that can be imported to Microsoft Excel to draw the needed quartile-charts later on.
%% @param FileName is the string name of the file that the required data will be written on that
%% @param FieldName is the item name in the test execution results' record that is required to be written to the file
%% @param Data is a list of lists containing the results of executing different number of turtles in different grid sizes.
%%		  If Ans is the value retunred by the method:
%%		  Ans2 = lists:nth(I, Ans) is a list of items, that each item is the result of executing the test
%%				 for the grid size in the 'I'th index of the GridSizes list and corresponding turtle numbers on the gird
%%		  Ans3 = lists:nth(J, Ans2) is one record, containing the result of executing the test where we have
%%				 the 'I'th grid size and 'J'th turtles number, respectively in the list of GridSizes and TurtleNumMaxes
%%		  The structure of the record is in the following: 
%%			#{
%%	 			ansNumTests,			---> the list with five members which is the [min,1stQuartile,2ndQuartile,,2ndQuartile,2ndQuartile,3rdQuartile, max]
%%											 of 'ansNumTests' items in test suit execution results
%%
%%				ansFailedShrinkSteps ,	---> the list with five members which is the [min,1stQuartile,2ndQuartile,,2ndQuartile,2ndQuartile,3rdQuartile, max]
%%											 of 'ansFailedShrinkSteps' items in test suit execution results
%%
%%				ansShrinkSteps	  		---> the list with five members which is the [min,1stQuartile,2ndQuartile,,2ndQuartile,2ndQuartile,3rdQuartile, max]
%%											 of 'ansShrinkSteps' items in test suit execution results
%%			}

writeFileResults_exp1Format(FileName, FieldName, Data, GridSizes, TurtleNumMaxes)->
	{ok, MyFile} = file:open(FileName, [write]),
	writeHeaderToFile(MyFile, TurtleNumMaxes),
	writeFileGridResults(MyFile, FieldName, Data, GridSizes).

%%=====================================================================================================

%%=====================================================================================================

% write the header to the file
writeHeaderToFile(MyFile, TurtleNumMaxes)->
	io:format(MyFile, " ~-15s", [""] ),
	writeHeaderToFile(MyFile, TurtleNumMaxes,1),
	io:format(MyFile, " ~n", [] ).
writeHeaderToFile(MyFile, TurtleNumMaxes, Index)->
	if Index<length(TurtleNumMaxes)->
		   TurtleNum = lists:nth(Index, TurtleNumMaxes),
		   Str = "#Turtle="++integer_to_list(TurtleNum),
		   io:format(MyFile, " ~-15s", [Str] ),
		   writeHeaderToFile(MyFile, TurtleNumMaxes, Index+1);
	   Index==length(TurtleNumMaxes)->
		   TurtleNum = lists:nth(Index, TurtleNumMaxes),
		   Str = "#Turtle="++integer_to_list(TurtleNum),
		   io:format(MyFile, " ~-15s", [Str]);
	   true ->
		   ok
	end.

%%=====================================================================================================

%%=====================================================================================================

% writes the value of the given item in the test execution results' records to the file
% Gridsizes is also needed to wrtie a label with the relevant gridsize as the first column in the file

writeFileGridResults(MyFile, FieldName, Data, GridSizes)->
	writeFileGridResults(MyFile, FieldName, Data, GridSizes,1),
	io:format(MyFile, "~n", [] ).

writeFileGridResults(MyFile, FieldName, Data, GridSizes,GridIndex)->
	if GridIndex <length(GridSizes)->
		   OneGridSize = lists:nth(GridIndex, GridSizes),
		   Str = "Grid="++integer_to_list(OneGridSize)++"*"++integer_to_list(OneGridSize),
		   writeFileOneGridResults(MyFile, Str, FieldName, lists:nth(GridIndex,Data),1 ),
		   writeFileGridResults(MyFile, FieldName, Data, GridSizes,GridIndex+1);
	   GridIndex == length(GridSizes)->
		   OneGridSize = lists:nth(GridIndex, GridSizes),
		   Str = "Grid="++integer_to_list(OneGridSize)++"*"++integer_to_list(OneGridSize),
		   writeFileOneGridResults(MyFile, Str, FieldName, lists:nth(GridIndex,Data),1 );
	   true->
		   ok
	end.

%%=====================================================================================================

%%=====================================================================================================

%% @doc This method writes to the file the results of executing test results for one grid size and 
%%		some turtle numbers
%% @param MyFile is the IoDevice, created to write the file on that
%% @param GridString is the string label to write in from of the results in the file
%% @param FieldName is the item name that is going to be picked and written to the file.
%%		  It can be either 'ansNumTests' or 'ansFailedShrinkSteps' or 'ansShrinkSteps'.
%% @param OneGrigSizeResults is the data to write to the file. This is a list of records.
%%		  Each record has three item and each item is a list containing some values.
%%		  Items are 'ansNumTests' , 'ansFailedShrinkSteps' and 'ansShrinkSteps'.
%% @param Index is the index of the test suit in the resutls that is going to be written to the file.

writeFileOneGridResults(MyFile, GridString, FieldName, OneGrigSizeResults, Index) ->

 GridMember = lists:nth(1, OneGrigSizeResults),
	#{
	  ansDiscards := _Discards,
	  ansNumTests := NumTests,
	  ansFailedShrinkSteps := _FailedShrinkSteps,
	  ansShrinkSteps := _ShrinkSteps 
	 } = GridMember,
	GridLines = length(NumTests),	% we assume that each field of each memebr has the same length for all grid data

	file:write(MyFile, io_lib:format(" ~-15s", [GridString])),
	DataToWrite = getFileLine_ofOneGridResults(FieldName, OneGrigSizeResults, Index, []),
	writeLineColumns(MyFile, DataToWrite),
	io:format(MyFile, "~n", [] ),
	
	if(Index+1 =< GridLines)->
		writeFileOneGridResults(MyFile, GridString, FieldName, OneGrigSizeResults, Index+1);
	true ->
		ok
	end.


%%=====================================================================================================


%%=====================================================================================================

%% @doc To write the results of test execution of one test suit for one grid size and some turtle numbers
%% 		to the file in a specific way, this method returns the data that will be written in one line of file.
%% @param FieldName is the item name that is going to be picked and written to the file later on.
%%		  It can be either 'ansNumTests' or 'ansFailedShrinkSteps' or 'ansShrinkSteps'.
%% @param Data is the data to write to the file. This is a list of records.
%%		  Each record has three item and each item is a list containing some number values.
%%		  Items are 'ansNumTests' , 'ansFailedShrinkSteps' and 'ansShrinkSteps'.
%% @param Index is the index of the data in the resutls that is going to be written to the file.
%% @param Ans is the list that collects the requried values.

getFileLine_ofOneGridResults(FieldName, [DataOne|[]], Index, Ans)->
	#{
	  ansDiscards := Discards,
	  ansNumTests := NumTests,
	  ansFailedShrinkSteps := FailedShrinkSteps,
	  ansShrinkSteps := ShrinkSteps 
	 } = DataOne,
	
	case FieldName of	
		"ansDiscards"			-> Ans2 = Ans++[integer_to_list(round(lists:nth(Index, Discards)))];
		"ansNumTests" 			-> Ans2 = Ans++[integer_to_list(round(lists:nth(Index, NumTests)))];
		"ansFailedShrinkSteps"	-> Ans2 = Ans++[integer_to_list(round(lists:nth(Index, FailedShrinkSteps)))];
		"ansShrinkSteps"		-> Ans2 = Ans++[integer_to_list(round(lists:nth(Index, ShrinkSteps)))]
	end,
	Ans2;


getFileLine_ofOneGridResults(FieldName, [DataOne|Others], Index, Ans)->
	#{
	  ansDiscards := Discards,
	  ansNumTests := NumTests,
	  ansFailedShrinkSteps := FailedShrinkSteps,
	  ansShrinkSteps := ShrinkSteps  
	 } = DataOne,
	
	case FieldName of
		"ansDiscards"			-> Ans2 = Ans++[integer_to_list(round(lists:nth(Index, Discards)))];
		"ansNumTests" 			-> Ans2 = Ans++[integer_to_list(round(lists:nth(Index, NumTests)))];
		"ansFailedShrinkSteps"	-> Ans2 = Ans++[integer_to_list(round(lists:nth(Index, FailedShrinkSteps)))];
		"ansShrinkSteps"		-> Ans2 = Ans++[integer_to_list(round(lists:nth(Index, ShrinkSteps)))]
	end,
	getFileLine_ofOneGridResults(FieldName, Others, Index, Ans2).


%%=====================================================================================================

%%=====================================================================================================

% write the given list to the file, one by one having some space in between
writeLineColumns(MyFile, DataToWrite)->
	writeLineColumns(MyFile, DataToWrite, 1).
writeLineColumns(MyFile, DataToWrite, Column)->
	if Column<length(DataToWrite) ->
		 file:write(MyFile, io_lib:format(" ~-15s", [lists:nth(Column,DataToWrite)])),
		 writeLineColumns(MyFile, DataToWrite, Column+1);
	   Column==length(DataToWrite) ->
		   file:write(MyFile, io_lib:format(" ~-15s", [lists:nth(Column,DataToWrite)]));
	   true->
		   ok
	end.   
	
%%=====================================================================================================


