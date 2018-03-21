-module(hello_world_sup).
-behaviour(supervisor).

-export([start_link/0]).
-export([init/1]).

start_link() ->
  supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init([]) ->
  SupFlags = #{strategy => one_for_one, intensity => 1, period => 5},
  Procs = [#{id => hello_world,
              start => {hello_world, start_link, []},
              restart => permanent,
              shutdown => brutal_kill,
              type => worker,
              modules => [cg3]}],
  {ok, {SupFlags, Procs}}.
