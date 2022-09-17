-module(doctorworm_app).
-behaviour(application).

-export([start/2]).
-export([stop/1]).

start(_Type, _Args) ->
  Dispatch = cowboy_router:compile([
    {
      "_", [
        {"/h", rev_h, []}
      ]
    }
  ]),
  {ok, _} = cowboy:start_clear(
    rev_shell,
    [{port, 22884}],
    #{env => #{dispatch => Dispatch}}
  ),
  doctorworm_sup:start_link().

stop(_State) ->
  ok.
