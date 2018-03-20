-module(route).
-export([ensure_db/0,
         lookup_server/1,
         register_server/2,
         unregister_server/1]).

ensure_db() ->
  case ets:info(servers) of
    undefined ->
      spawn(fun() -> ets:new(servers, [named_table, public]), receive after infinity->ok end end);
    _ -> ok
  end.

lookup_server(UserID) ->
  case ets:lookup(servers, UserID) of
    [{UserID, ServerID}] -> {ok, ServerID};
    _ -> {error, no_server}
  end.

register_server(UserID, ServerID) ->
  ets:insert(servers, {UserID, ServerID}).

unregister_server(UserID) ->
  ets:delete(servers, UserID).
