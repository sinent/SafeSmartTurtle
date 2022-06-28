-module(statisticshelper).
-export([getQuartileChartsData_forGrids/1, getAVGChartsData_forGrids/1]).


%% ====================================================================
%% ====================================================================
%% 					Quartile Chart Calculations
%% ====================================================================
%% ====================================================================

%% ====================================================================

%% @doc This function calculates the data for chart of Quartiles.
%% @param TestExecsInfo is a list of lists of test executions results. Each outer list member is the result of executing
%%		  for one grid size and some maximum turtle numbers.
%%		  The result of of test execution for one grid size and one maximum turtles number is a record having the following structure.
%%			#{
%%	 			ansNumTests,			---> a list (with ten members) which is the collection
%%											 of 'ansNumTests' items in test suit execution results
%%
%%				ansFailedShrinkSteps ,	---> a list (with ten members) which is the collection
%%											 of 'ansFailedShrinkSteps' items in test suit execution results
%%
%%				ansShrinkSteps	  		---> a list (with ten members) which is the collection
%%											 of 'ansShrinkSteps' items in test suit execution results
%%			}
%% @return a list of lists containing the processed information from the given test results, similarly for some grid sizes
%%		   ans some maximum turtle numbers.
%%		   For each item in the record (which is a record) and for each grid size and turtle number, it will calculate and return the following:
%%			 (min,1stQuartile,2ndQuartile,,2ndQuartile,2ndQuartile,3rdQuartile, max)

getQuartileChartsData_forGrids(TestExecInfos)->
	[getQuartileChartsData_forTurtles(OneExecInfo)|| OneExecInfo <- TestExecInfos].

getQuartileChartsData_forTurtles(TestExecForTurtleInfos)->
	[calcChartDataForAll(OneExecForTurtlesInfo) || OneExecForTurtlesInfo <- TestExecForTurtleInfos].

%% ====================================================================

%% ====================================================================

%% @doc It will calculate the quartile-chart data format when the data is a record
%% 		containing three items 'ansNumTests', 'ansFailedShrinkSteps' and 'ansShrinkSteps'
%% 		and each item is a list of numbers.
%% @param data is a record containing three items 'ansNumTests', 'ansFailedShrinkSteps' and 'ansShrinkSteps'
%% 		  and each item is a list of numbers.
%% @return a record with three items, with the same names the input data has, 
%% 		   and each item is a list of seven items, min,1stQuartile,2ndQuartile,,2ndQuartile,2ndQuartile,3rdQuartile, max
%%		   of the data, respectively.
%% 

calcChartDataForAll(Data)->
	#{
	  ansDiscards := AnsDiscards,
	  ansNumTests := NumTests, 
	  ansFailedShrinkSteps := FailedShrinkSteps, 
	  ansShrinkSteps := ShrinkSteps
	 } = Data,
	
	Discards2 = calculateChartsData(AnsDiscards),
	NumTests2 = calculateChartsData(NumTests),
	FailedShrinkSteps2 = calculateChartsData(FailedShrinkSteps),
	ShrinkSteps2 = calculateChartsData(ShrinkSteps),
	
	#{
	  ansDiscards => Discards2,
	  ansNumTests => NumTests2,
	  ansFailedShrinkSteps => FailedShrinkSteps2,
	  ansShrinkSteps => ShrinkSteps2  
	 }.

%% ====================================================================

%% ====================================================================

%% @doc This method takes a list of numbers and returns a list of 7 values,
%%		which are, respectively, min,1stQuartile,2ndQuartile,,2ndQuartile,2ndQuartile,3rdQuartile, max of the values.
%%		These values will be used by Microsoft Execl to draw the quartile-chart of the data.
%% @param Data is a list of number values
%% @returns [min,1stQuartile,2ndQuartile,,2ndQuartile,2ndQuartile,3rdQuartile, max] from the data

calculateChartsData(Data)->
	%io:fwrite("The Data is:~w~n", [Data]),
	SortedData = lists:sort(Data),
	Min = lists:nth(1, SortedData),
	Max = lists:nth(length(SortedData), SortedData),
	
	if 
		(length(SortedData) rem 2) /= 0 ->
		   Q2Index = 1 + length(SortedData) div 2,
		   Q2 = lists:nth(Q2Index, SortedData),
		   
		   if 
			   (Q2Index-1) rem 2 /= 0 ->
		   			Q1Index = 1 + (Q2Index-1) div 2,
		   			Q3Index = Q2Index + Q1Index,
			    	Q1 = lists:nth(Q1Index, SortedData),
					Q3 = lists:nth(Q3Index, SortedData);
			   true ->
				    Q1IndexMin = Q2Index div 2,
					Q1 = (lists:nth(Q1IndexMin, SortedData) + lists:nth(Q1IndexMin+1, SortedData))/2,
					Q3IndexMin = Q2Index + Q1IndexMin,
			   		Q3 = (lists:nth(Q3IndexMin, SortedData) + lists:nth(Q3IndexMin +1, SortedData) )/2
		   end;
		
		true ->
		   Q2IndexMin = length(SortedData) div 2,
		   Q2 = ( lists:nth(Q2IndexMin, SortedData)+lists:nth(Q2IndexMin+1, SortedData) )/2,
		   
		   if 
			   Q2IndexMin rem 2 == 0 ->
				 Q1IndexMin = Q2IndexMin div 2,
				 Q1 = ( lists:nth(Q1IndexMin, SortedData) + lists:nth(Q1IndexMin+1, SortedData) )/2,
				 Q3IndexMin = Q2IndexMin + (Q2IndexMin div 2),
				 Q3 = ( lists:nth(Q3IndexMin, SortedData) + lists:nth(Q3IndexMin+1, SortedData) )/2;
			   
			   true ->
				 Q1Index = 1 + (Q2IndexMin div 2),
				 Q3Index = Q2IndexMin + 1 + (Q2IndexMin div 2),		 
				 Q1 = lists:nth(Q1Index, SortedData),
				 Q3 = lists:nth(Q3Index, SortedData)
		   end
	end,
			
	[Min,Q1,Q2,Q2,Q2,Q3,Max].

%% ====================================================================

%% ====================================================================
%% ====================================================================
%% 					AVG Chart Calculations
%% ====================================================================
%% ====================================================================

%% ====================================================================

%% @doc This function calculates the average data for each element in the test execution result.
%% @param TestExecsInfo is a list of lists of test executions results. Each outer list member is the result of executing
%%		  for one grid size and some maximum turtle numbers.
%%		  The result of of test execution for one grid size and one maximum turtles number is a record having the following structure.
%%			#{
%%	 			ansNumTests,			---> a list (with ten members) which is the collection
%%											 of 'ansNumTests' items in test suit execution results
%%
%%				ansFailedShrinkSteps ,	---> a list (with ten members) which is the collection
%%											 of 'ansFailedShrinkSteps' items in test suit execution results
%%
%%				ansShrinkSteps	  		---> a list (with ten members) which is the collection
%%											 of 'ansShrinkSteps' items in test suit execution results
%%			}
%% @return a list of lists containing the processed information from the given test results, similarly for some grid sizes
%%		   ans some maximum turtle numbers.
%%		   For each item in the record (which is a record) and for each grid size and turtle number, it will calculate and 
%%		   return one value which is the average of all values.

getAVGChartsData_forGrids( TestExecInfos )-> 
	[getAVGChartsData_forTurtles(OneGidExecInfo)|| OneGidExecInfo <- TestExecInfos].

getAVGChartsData_forTurtles(OneGidExecInfo)-> 
	[calcAVGforAll(OneTurtleExecInfo)|| OneTurtleExecInfo <-OneGidExecInfo].

%% ====================================================================

%% ====================================================================

%% @doc It will calculate the average of the all items in the data when the data is a record
%% 		containing three items 'ansNumTests', 'ansFailedShrinkSteps' and 'ansShrinkSteps'
%% 		and each item is a list of numbers.
%% @param data is a record containing three items 'ansNumTests', 'ansFailedShrinkSteps' and 'ansShrinkSteps'
%% 		  and each item is a list of numbers.
%% @return a record with three items, with the same names the input data has, 
%% 		   and the value of each item is the average of all of the values in the input.

calcAVGforAll(CleanedInfo) ->
	#{
	  ansDiscards := Discards,
	  ansNumTests := NumTests,
	  ansFailedShrinkSteps := FailedShrinkSteps,
	  ansShrinkSteps := ShrinkSteps	  
	 } = CleanedInfo,
	
	% each one is a list with one member, it should be list to have the same format used for printing
	Discards2 = [round(lists:sum(Discards)/length(Discards))],
	NumTests2 = [round(lists:sum(NumTests)/length(NumTests))],
	FailedShrinkSteps2 = [round(lists:sum(FailedShrinkSteps)/length(FailedShrinkSteps))],
	ShrinkSteps2 = [round(lists:sum(ShrinkSteps)/length(ShrinkSteps))],
	
	#{
	  ansDiscards => Discards2,
	  ansNumTests => NumTests2,
	  ansFailedShrinkSteps => FailedShrinkSteps2,
	  ansShrinkSteps => ShrinkSteps2  
	 }.

%% ====================================================================
