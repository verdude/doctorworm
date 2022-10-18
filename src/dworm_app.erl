-module(dworm_app).
-behaviour(application).

-export([start/2]).
-export([stop/1]).

start(_Type, _Args) ->
    Dispatch = cowboy_router:compile([
                                      {'_', [
                                             {"/", rev, []}
                                            ]}
                                     ]),
    {ok, _} = cowboy:start_clear(http, [{port, 22884}], #{
                                                          env => #{dispatch => Dispatch}
                                                         }),
    dworm_sup:start_link().

stop(_State) ->
    ok = cowboy:stop_listener(http).
