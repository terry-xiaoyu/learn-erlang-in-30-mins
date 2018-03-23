-module(ss_chat_app).
-behaviour(application).

-export([start/2]).
-export([stop/1]).

start(_Type, _Args) ->
  Dispatch = cowboy_router:compile([
		{'_', [
			{"/", cowboy_static, {priv_file, ss_chat, "index.html"}},
			{"/websocket", ss_chat_ws, []},
			{"/static/[...]", cowboy_static, {priv_dir, ss_chat, "static"}}
		]}
	]),
	{ok, _} = cowboy:start_clear(http, [{port, 8080}], #{
		env => #{dispatch => Dispatch}
	}),
  ss_chat_sup:start_link().

stop(_State) ->
  ok.
