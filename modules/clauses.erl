-module(clauses).
-export([add/2]).

%% goes into this clause when both A and B are numbers
add(A, B) when is_number(A), is_number(B) ->
  A + B;
%% goes this clause when both A and B are lists
add(A, B) when is_list(A), is_list(B) ->
  A ++ B.
%% crashes when no above clauses matched.
