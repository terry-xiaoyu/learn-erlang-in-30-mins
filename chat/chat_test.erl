-module(chat_test).
-compile(export_all).

-include("chat_protocol.hrl").

test_startup() ->
  route:ensure_db().

test_client_connected(UserID) ->
  chat_server:start_link(UserID, fake_socket).

test_msg_received_from_client(ServerID, FromUserID, ToUserID, Payload) ->
  ServerID ! {tcp, #msg{from_userid=FromUserID, to_userid = ToUserID, payload = Payload}},
  ok.
