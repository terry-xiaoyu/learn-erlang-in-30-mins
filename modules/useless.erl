-module(useless).
-export([add/2]).  %%   export 是导出语法，指定导出 add/2 函数

add(A,B) ->
  A + B.
