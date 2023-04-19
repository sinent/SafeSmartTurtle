-module(turtlesworld3).
% -export([run/4]).
-compile([export_all, nowarn_export_all]).

% turtlesworld3:run([{1, 0, 0, [up]}, {2, 1, 1, [up]}], 5, 5).
sampleInput()->
[{1,3,1,[up,up,nop,nop,nop,right,nop,down,nop,left]},
 {2,4,0,[down,left,left,nop,nop,nop,nop,right,down,nop]},
 {3,3,2,[down,nop,right,down,nop,right,up,nop,nop,nop]},
 {4,1,2,[nop,down,nop,nop,left,down,up,down,nop,nop]},
 {5,1,2,[nop,right,nop,down,nop,nop,nop,left,down,left]}].

removeLastNops(Moves)->
	Last = lists:last(Moves),
	if
		Last==nop -> removeLastNops(lists:droplast(Moves));
		true -> Moves
	end.

test()->
	[{ID,StartX,StartY,removeLastNops(Moves)}||{ID,StartX,StartY,Moves}<-sampleInput()].

run(InitialTurtlesPaths,TurtlesFaults,MaxX, MaxY) ->
	FileName = "SUT_Input.txt",
	% the wait steps after the last displacement steps are idle, so we remove them
	InitialPathsToExecute = [{ID,StartX,StartY,removeLastNops(Moves)}||{ID,StartX,StartY,Moves}<-InitialTurtlesPaths],
	writeInputToFile(InitialPathsToExecute,TurtlesFaults, MaxX, MaxY, FileName),
	JavaSUT_portNum = 1234,
	Self_portNum = 6789,
%% 	io:fwrite("opening the socket~n"),
	{ok, Socket} = gen_udp:open(Self_portNum),
%% 	io:fwrite("socket is opened successfully..~n"),
	spawn(fun()->listen(Socket, self()) end),
%% 	io:fwrite("requested for testing..~n"),
	gen_udp:send(Socket,"localhost",JavaSUT_portNum,FileName),
%% 	io:fwrite("waiting for the result..~n"),
	{_udp, _port,_Server, _portNum, TestReport} = receive Inp -> Inp end,
	gen_udp:close(Socket),
	if 
		TestReport == "Fail"-> 
			begin
				io:fwrite("Failed Test.~n"),
%% 				io:fwrite(TestReport),
				false
			end;
		true-> 
			begin
				io:fwrite("Successful Test.~n"),
%% 				io:fwrite(TestReport),
				true
			end
	end.
	
	

listen(Socket, Pid)->
%% 	io:fwrite("waiting for the result in a new thread..~n"),
	Message = gen_udp:recv(Socket, 0),
	Pid ! Message.

writeInputToFile(InitialTurtlesPaths,TurtlesFaults, MaxX, MaxY,FileName)->
	% io:fwrite("writing is started.~n"),
	{ok, MyFile} = file:open(FileName, [write]),
	PathsFaults = lists:zip(InitialTurtlesPaths,TurtlesFaults),
	io:format(MyFile, "Grid Size: (~s,~s)~n", [integer_to_list(MaxX),integer_to_list(MaxY)] ),
	[begin
		 {Paths,Faults} = PathFault,
		 {ID, StartX, StartY, Moves} = Paths,
		 io:format(MyFile, "Turtle ID:~s - Start: (~s,~s) - Moves:", [integer_to_list(ID),integer_to_list(StartX), integer_to_list(StartY)]),
		 [begin
			io:format(MyFile, "~s,", [atom_to_list(Move)])
		  end
		 ||Move<-Moves],
		 io:format(MyFile, " - Faults:~s",[""]),
		 [begin
			io:format(MyFile, "~s,", [integer_to_list(Fault)])
		  end
		 ||Fault<-Faults], 
		 io:format(MyFile, "~s~n", [""])	 
	 end|| PathFault <- PathsFaults],
	file:close(MyFile).
	% io:fwrite("writing is finished.~n").

