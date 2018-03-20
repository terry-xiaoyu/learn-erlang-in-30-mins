-module(chat_server).

-behaviour(gen_server).

-include("chat_protocol.hrl").

%% API functions
-export([start_link/2]).

%% gen_server callbacks
-export([init/1,
         handle_call/3,
         handle_cast/2,
         handle_info/2,
         terminate/2,
         code_change/3]).

-record(state, {
  userid,
  socket
}).

%%%===================================================================
%%% API functions
%%%===================================================================
start_link(UserID, Socket) ->
  {ok, ServerID}  = gen_server:start_link(?MODULE, [UserID, Socket], []),
  ServerID.

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================
init([UserID, Socket]) ->
    process_flag(trap_exit, true),
    route:register_server(UserID, self()),
    {ok, #state{userid=UserID, socket=Socket}}.

handle_call({send, #msg{payload = Payload}}, _From, State) ->
  io:format("Chat Server(User: ~p) - deliver msg to tcp client, Payload: ~p~n",
    [State#state.userid, Payload]),
  send_to_client_via_tcp(State#state.socket, Payload),
  {reply, ok, State};
handle_call(_Request, _From, State) ->
    Reply = ok,
    {reply, Reply, State}.

%% Suppose that we received a msg from tcp client
handle_info({tcp, #msg{to_userid = ToUserID, payload = Payload} = Msg}, State) ->
  io:format("Chat Server(User: ~p) - received msg from tcp client, Msg: ~p~n",[State#state.userid, Msg]),
  case route:lookup_server(ToUserID) of
    {error, Reason} ->
      io:format("Chat Server(User: ~p) - cannot forward to Chat Server(User: ~p): ~p~n",
          [State#state.userid, ToUserID, Reason]);
    {ok, TargetServerID} ->
      io:format("Chat Server(User: ~p) - forward msg to Chat Server(User: ~p), Payload: ~p~n",
        [State#state.userid, ToUserID, Payload]),
      ok = gen_server:call(TargetServerID, {send, Msg})
  end,
  {noreply, State};
handle_info(_Info, State) ->
    {noreply, State}.

handle_cast(_Msg, State) ->
    {noreply, State}.

terminate(_Reason, State) ->
    route:unregister_server(State#state.userid),
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
send_to_client_via_tcp(_Socket, Payload) ->
  %gen_tcp:send(_Socket, Payload),
  io:format("Sent To Client: ~p~n",[Payload]).
