-module(case_matching).
-export([greet/2]).

greet(Gender, Name) ->
  case Gender of
    male ->
      io:format("Hello, Mr. ~s!~n", [Name]);
    female ->
      io:format("Hello, Mrs. ~s!~n", [Name]);
    _ ->
      io:format("Hello, ~s!~n", [Name])
  end.
