-module(msg_cache).

%% APIs
-export([start_one/1,
         get_name/1,
         get_length/1,
         pop/1,
         set_name/2,
         push/2
        ]).

%% for spawns
-export([loop/1]).

-define(API_TIMEOUT, 3000).

-record(state, {
            name,
            length = 0,
            buff = []
         }).

start_one(BuffName) ->
  Pid = spawn(msg_cache, loop, [#state{name=BuffName}]),
  io:format("Buff ~s created! Pid = ~p~n", [BuffName, Pid]),
  Pid.

get_name(CacheID) ->
  call(CacheID, {get_name, self()}).
get_length(CacheID) ->
  call(CacheID, {get_length, self()}).
set_name(CacheID, NewName) ->
  call(CacheID, {set_name, NewName, self()}).
pop(CacheID) ->
  call(CacheID, {pop, self()}).
push(CacheID, Msg) ->
  call(CacheID, {push, Msg, self()}).

call(Pid, Request) ->
  Pid ! Request,
  receive
    Response -> Response
  after ?API_TIMEOUT ->
    {error, api_timeout}
  end.

loop(State = #state{name = Name, length = Len, buff = Buff}) ->
  receive
    {get_name, From}->
      From ! {ok, Name},
      loop(State);
    {get_length, From}->
      From ! {ok, Len},
      loop(State);
    {set_name, NewName, From} ->
      From ! ok,
      loop(State#state{name = NewName});
    {push, Msg, From} ->
      From ! ok,
      loop(State#state{buff = [Msg | Buff], length = Len + 1});
    {pop, From} ->
      case Buff of
        [] ->
          From ! {error, empty},
          loop(State);
        [TopMsg | Msgs] ->
          From ! {ok, TopMsg},
          loop(State#state{buff = Msgs, length = Len - 1})
      end;
    _Unsupported ->
      erlang:error(io_libs:format("unsupported msg: ", [_Unsupported]) )
  end.
