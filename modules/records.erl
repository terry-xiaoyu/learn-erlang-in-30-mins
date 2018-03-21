-module(records).

-export([get_user_name/1,
         get_user_phone/1]).

-record(user, {
  name,
  phone
}).

get_user_name(#user{name=Name}) ->
  Name.

get_user_phone(#user{phone=Phone}) ->
  Phone.

