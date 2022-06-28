-module(turtlesworld2).
-export([run/3]).

% turtlesworld2:run([{1, 0, 0, [up]}, {2, 1, 1, [up]}], 5, 5).

run(InitialTurtlesPaths, MaxX, MaxY) ->
%	%io:format("Given input: ~w~n",[InitialTurtlesPaths]),
    % Add enter events in front of every path to place the turtle
    % on the grid and then kick off the first step
    step([{Id, X, Y, [enter | Path]} || {Id, X, Y, Path} <- InitialTurtlesPaths], [], MaxX, MaxY, 1).

step(RunningTurtles, Trace, MaxX, MaxY, Step) ->
	% List the turtles that want to enter and their
	% initial positions if they are currently free
	StandbyTurtles = [
	   {Id, X, Y} || {Id, X, Y, TPath} <- RunningTurtles,
		length(TPath) > 1 andalso
		hd(TPath) == enter andalso
		clear_position(X, Y, RunningTurtles)],
	% find entries with repeated X,Y and pick only one of them to allow
	% entry
	EntryIds = [
	   hd([Id || {Id, XX, YY} <- StandbyTurtles, XX == X andalso YY == Y])
	   || {X, Y} <- sets:to_list(sets:from_list([{X,Y} || {_, X, Y} <- StandbyTurtles]))],
	% First put the possible standby turtles on the grid
	{RunningTurtlesAfterEntry, TraceAfterEntry} =
		move_turtles(enter, EntryIds, RunningTurtles, Trace, MaxX, MaxY, Step),
	% Get the Ids of the turtles that decide they can / should move
	MoveIds = [Id || {Id, _X, _Y, _TPath} <- RunningTurtlesAfterEntry,
	        evaluate_next_step(RunningTurtlesAfterEntry, Id, MaxX, MaxY)],
	case MoveIds of
		% No more moves possible (either all finished or deadlocked), we quit
		[] -> lists:reverse(Trace);
		_ -> % Move the turtles one step
		     {NewRunningTurtles, NewTrace} =
		        move_turtles(move, MoveIds, RunningTurtlesAfterEntry, TraceAfterEntry, MaxX, MaxY, Step),
		     % check if any two turtles occupy the same position, if so, report this for the first
		     % found occurence as collision and terminate
		     GridOccupation = [
		           {X,Y, [Id || {Id, X2, Y2, _} <- NewRunningTurtles, X == X2 andalso Y == Y2]}
			|| {_, X, Y, _} <- NewRunningTurtles],
		     case [{X, Y, hd(Ids)} || {X, Y, Ids} <- GridOccupation, length(Ids) > 1] of
			     [{CX, CY, Id} | _] -> lists:reverse([format_trace_item(collision, Id, CX, CY, Step) | NewTrace]);
		             % No collision, we can go on to the next step
		     	     [] -> step(NewRunningTurtles, NewTrace, MaxX, MaxY, Step+1)
		     end
	end.

% Evaluate the possibility to make the next move,
% first check that we actually have some path left
% or that perhaps our next move is nop, which is always
% possible.
% Otherwise delegate to the core decision making logic.
evaluate_next_step(RunningTurtles, Id, MaxX, MaxY) ->
	[{Id, X, Y, TPath}] =
	   [{I, X, Y, Path} || {I, X, Y, Path} <- RunningTurtles, I == Id],
	case TPath of
		% Can't move if the route is already empty
		[] -> false;
		% We can always "move" if we plan nop
		[nop | _] -> true;
		[Move | _] ->
			{_D, NX, NY} = move(Move, X, Y, MaxX, MaxY),
			decide_next_step(X, Y, Move, NX, NY, RunningTurtles)
	end.

% This is the core decision to move, we check if our
% immediate next spot is currently free, if so we say yes,
% it may be that another turtle will decide to move there too.
% We may do something different, check that the position is free
% and then flip a coin to decide if we really want to move, or
% check one fixed neighbour of NX, NY to see if it is occupied
% and if so decide to wait, etc. etc.
decide_next_step(_X, _Y, _Move, NX, NY, RunningTurtles) ->
	clear_position(NX, NY, RunningTurtles).

move_turtles(Stage, Ids, RunningTurtles, Trace, MaxX, MaxY, Step) ->
	{ToMoveTurtles, ToStayTurtles} =
	   lists:partition(
	      fun({Id, _, _, _}) -> lists:member(Id, Ids) end,
	      RunningTurtles),
	{MovedTurtles, NewTrace} = lists:unzip([
          begin
	    {Dir, NX, NY} = move(Move, X, Y, MaxX, MaxY),
	    {{Id, NX, NY, Rest}, format_trace_item(Dir, Id, NX, NY, Step)}
          end
	|| {Id, X, Y, [Move | Rest]} <- ToMoveTurtles]),
	{lists:sort(MovedTurtles ++ ToStayTurtles),
	  case Stage of
            move ->
	       [ format_trace_item(stay, Id, X, Y, Step) ||
	           {Id, X, Y, _} <- ToStayTurtles];
            _ -> []
          end ++ NewTrace ++ Trace}.

clear_position(_, _, []) ->
    true;
clear_position(TargetX, TargetY, [ {_, X, Y, Path} | RunningTurtles]) ->
    % Turtles that did not yet enter do not occupy their initial position
    Enter = case Path of
	    [enter | _] -> true;
            _ -> false
    end,
    (not (TargetX == X andalso TargetY == Y) orelse Enter) andalso
        clear_position(TargetX, TargetY, RunningTurtles).

format_trace_item(Action, Idx, X, Y, Step) ->
    {{event, Action}, {id, Idx}, {x, X}, {y, Y}, {step, Step}}.

move(enter, X, Y, MaxX, MaxY) when X < MaxX andalso Y < MaxY ->
    {enter, X, Y};
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
