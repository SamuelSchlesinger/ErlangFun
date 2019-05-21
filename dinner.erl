-module(dinner).
-compile(export_all).

fork(I, noone) ->
  receive
    Pid -> Pid ! Pid, io:format("~p grabbed ~p~n", [Pid, I]), fork(I, Pid)
  end;
fork(I, Pid) ->
  receive
    Pid -> Pid ! noone, io:format("~p put down ~p~n", [Pid, I]), fork(I, noone);
    Pid2 -> Pid2 ! Pid, fork(I, Pid)
  end.

tryFork(Fork) ->
  Fork ! self(),
  receive Pid ->
    if Pid == self() ->
        io:format("~p is eating~n", [self()]),
        timer:sleep(rand:uniform(500) + 500),
        Fork ! self(),
        good;
       Pid /= self() -> bad
    end
  end.

eater(T, Left, Right) ->
  case tryFork(Left) of
    good -> io:format("~p is finished eating~n", [self()]), eater(0, Right, Left);
    bad  -> if T > 10 -> io:format("~p: I'm hungry!!!!!!!!!!!!!!!!!!!!!!!!!!!!!~n", [self()]),
                         timer:sleep(500),
                         eater(0, Right, Left);
               true   -> timer:sleep(500),
                         eater(T + 1, Right, Left)
            end
  end.

makeEaters(Table) ->
  [First|_] = Table,
  makeEaters(First, Table).

makeEaters(First, [Last]) ->
  spawn(first, eater, [0, Last, First]);
makeEaters(First, [A, B | Rest]) ->
  spawn(first, eater, [0, A, B]),
  makeEaters(First, [B|Rest]).

eatDinner(N) ->
  Table = [ spawn(first, fork, [I, noone]) || I <- lists:seq(1, N) ],
  makeEaters(Table).
