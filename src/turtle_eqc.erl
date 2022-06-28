%%% @author Thomas Arts
%%% @doc
%%%
%%% @end
%%% Created : 16 Sep 2020 by Thomas Arts

-module(turtle_eqc).

-include_lib("eqc/include/eqc.hrl").

-compile([export_all, nowarn_export_all]).

%% Generators

turtle() ->
    ?LET(N, choose(0, 100),
         vector(N, elements([nop, left, right, up, down]))).

%% Property

prop_turtle() ->
    ?FORALL(Turtles, non_empty(list(turtle())),
             begin
                 %% reset the turtle environment
                 %% save the turtle files.
                 [ write_file(FileName, Movements)  || {FileName, Movements} <-  lists:zip(filenames(Turtles), Turtles) ],
                 %% Start turtles (N).  where N is the. length of the list Turtles
                 timer:sleep(1000),
                 %% check that the result is not a crash
                 length(lists:append(Turtles)) < 20
             end).

filenames(Ts) ->
	Name = fun(N) -> "turtle-" ++ integer_to_list(N) end,
        [ Name(N)  || N <- lists:seq(1, length(Ts))].

write_file(FileName, Movements) ->
    io:format("Writing ~s:\n~p\n", [FileName, Movements]).
