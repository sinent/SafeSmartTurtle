-module(turtlesworld).
-export([run/3]).

%%=====================================================================================================

%%Auxilliary method to call the step method with six parameters

run(StandbyTurtlesPaths, MaxX, MaxY) ->
	%io:format("Given input: ~w~n",[StandbyTurtlesPaths]),
    step([], StandbyTurtlesPaths, [], MaxX, MaxY,1).

%%=====================================================================================================

%%=====================================================================================================

%% @doc This method runs all turtles in the grid.
%%		The running algorithm devides the turtles to two parts: the turtles that are not placed to the board yet, and the turtles that
%%		are placed there, called 'standby' turtles and 'running' turtles respectively.
%%		The algorithms will try to first move the running turtles for one step 
%%		and then try to place the standbyTurtles on the board and save the trace of actions.            
%%		The process finshes if all turtles finishe their path, or there is a collision between turtles, 
%%		or there is no way to move for the turtles on the board (DeadLock case: they are waiting for each other to make the resources avaiable).
%% @param RunningTurtlesPaths: The turtles which are already placed to the board
%% @param StandbyTurtlesPaths: The turtles that are not yet placed to the board
%% @param Trace: The trace of movements which are done by the turtles in the board 
%% @param MaxX: The x-axis length of the board containing turtles
%% @param MaxY: The y-axis length of the board containing turtles
%% @param StepNo: The numer of this step
%% @returns Trace: The list of movements for the turtles, from the first move to the last one.

step([], [], Trace, _MaxX, _MaxY, _StepNo) -> 
    lists:reverse(Trace);
step(RunningTurtlesPaths, StandbyTurtlesPaths, Trace, MaxX, MaxY, StepNo) ->
    {Running1, UpdateTrace1} =
        step_running(RunningTurtlesPaths, Trace, MaxX, MaxY, StepNo),
    {Running2, NewStandby, UpdateTrace2} =
        step_start(Running1, StandbyTurtlesPaths, UpdateTrace1, StepNo),
    
	%% detect deadlock (no new move possible)
    case Running2 == RunningTurtlesPaths of
        false ->
            step(Running2, NewStandby, UpdateTrace2, MaxX, MaxY, StepNo+1);
        true ->
            lists:reverse(Trace)
    end.

%%=====================================================================================================

%%=====================================================================================================

%% @param RunningTurtlesPaths: The turtles which are already placed to the board
%% @param Trace: The trace of movements which are done by the turtles in the board 
%% @param MaxX: The x-axis length of the board containing turtles
%% @param MaxY: The y-axis length of the board containing turtles
%% @param StepNo: The step number in the trace
%% @returns {UpdatedRunningTurtlesPaths, UpdatedTrace}: for the given input, each turtle will try to move one step, and the result of moving will be stored in the trace                 
%%       											    and the position of the running turtles will be updated. If any collision is faced, further moving
%%													    of the sub list of moving turtles (led to collision) will be stopped (by eliminating them from the
%%													    list of running turtles).

step_running([], Trace, _, _, _) ->
    {[], Trace};
step_running([{Idx, X, Y, Path} | RunningTurtlesPaths], Trace, MaxX, MaxY, StepNo) ->
    {UpdatedRunningTurtlesPaths, UpdatedTrace} = step_running(RunningTurtlesPaths, Trace, MaxX, MaxY, StepNo),
    case clear_position(X, Y, UpdatedRunningTurtlesPaths) of
        false ->
            % Some turtle bumped into this one: collision
            {[], [format_trace_item(collision, Idx, X, Y, StepNo) | UpdatedTrace]};
        true ->
            case Path of
                [] ->
                    {[{Idx, X, Y, Path} | UpdatedRunningTurtlesPaths], UpdatedTrace};
                [Direction | Rest] ->
                    {Action, NewX, NewY} = move(Direction, X, Y, MaxX, MaxY),
                    case clear_position(NewX, NewY, UpdatedRunningTurtlesPaths) of
                        true ->
                            {[{Idx, NewX, NewY, Rest} | UpdatedRunningTurtlesPaths],
                             [format_trace_item(Action, Idx, NewX, NewY,StepNo) | UpdatedTrace]};
                        false ->
                            % Collision into other turtle
                            {[], [format_trace_item(collision, Idx, NewX, NewY, StepNo),
                                  format_trace_item(Action, Idx, NewX, NewY, StepNo) | UpdatedTrace]}
                    end
            end
    end.

%%=====================================================================================================

%%=====================================================================================================

%% @doc This method tries to put the turtles on the board and update the list of the turtles on the board(running ones),
%%       stanby ones and the trace of actions up to now. If for a StanbyTurtle, the entering location is already occupied
%%		 by another turtle, it will still remain among the standby turtles. Otherwise, it will be put in the RunningTurtles
%%		 list and the trace (enter,id,x,y,StepNo) will be added to the traces. 
%% @param RunningTurtlesPaths: The turtles which are entered to the board
%% @param StandbyTurtlesPaths: The turtles that are not still entered to the board
%% @param Trace: The trace of movements which are done by the turtles in the board 
%% @param StepNo: The number of current step (in the trace)
%% @returns {UpdatedRunningTurtles, UpdatedStandbyTurtles, UpdatedTrace}

step_start(RunningTurtlesPaths, [], Trace, _) ->
    {RunningTurtlesPaths, [], Trace};
step_start(RunningTurtlesPaths, [ {Idx, StartX, StartY, _Path} = OneStandbyTurtlePath | OtherStandbyTurtlesPaths], Trace, StepNo) ->
    {UpdatedRunningTurtlesPaths, UpdatedStandbyTurtlesPaths, UpdatedTrace} =
        step_start(RunningTurtlesPaths, OtherStandbyTurtlesPaths, Trace, StepNo),
    case clear_position(StartX, StartY, UpdatedRunningTurtlesPaths) of
        false ->
            {UpdatedRunningTurtlesPaths, [OneStandbyTurtlePath | UpdatedStandbyTurtlesPaths], UpdatedTrace};
        true ->
            {[OneStandbyTurtlePath | UpdatedRunningTurtlesPaths], UpdatedStandbyTurtlesPaths, [format_trace_item(enter, Idx, StartX, StartY, StepNo) | UpdatedTrace]}
    end.

%%=====================================================================================================


%% just formats an item that is appeared in a trace
format_trace_item(Action, Idx, X, Y, Step) ->
    {{event, Action}, {id, Idx}, {x, X}, {y, Y}, {step, Step}}.

%%=====================================================================================================

%% returns true if the current location of all turtles in RunningTurtlesPaths is not (StartX, StartY), false otherwise
clear_position(_StartX, _StartY, []) -> 
    true;

clear_position(StartX, StartY, [ {_, X, Y, _Path} | RunningTurtlesPaths]) ->
    not (StartX == X andalso StartY == Y) andalso
        clear_position(StartX, StartY, RunningTurtlesPaths).

%%=====================================================================================================

%% updating the position by moving towards different directions
%% 0<=x<=MaxX , 0<=y<=MaxY 
move(up, 	X, 		Y, 		_MaxX, 	MaxY)	when Y < MaxY 	->
    {up, 	X, 		Y + 1};			
move(down, 	X, 		Y, 		_MaxX, 	_MaxY) 	when Y > 0 		->
    {down, 	X, 		Y - 1};
move(left, 	X, 		Y, 		_MaxX, 	_MaxY) 	when X > 0 		->
    {left, 	X - 1, 	Y};
move(right, X, 		Y, 		MaxX, 	_MaxY) 	when X < MaxX 	->
    {right, X + 1, 	Y};
move(_, 	X, 		Y, 		_MaxX, 	_MaxY) ->
    {nop, 	X, 		Y}.

%%=====================================================================================================
