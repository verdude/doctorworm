-module(rev).

-export([init/2]).

-record(state, {
               }).

init(Req0=#{method = <<"GET">>}, _Opts) ->
  Req = cowboy_req:reply(200, #{}, <<"get">>, Req0),
  {ok, Req, #state{}}
init(Req0, _Opts) ->
    Req = cowboy_req:reply(200,
                           #{<<"content-type">> => <<"application/json">>},
                           <<"i live like a worm.">>,
                           Req0),
    {ok, Req, #state{}}.
