-module(http).

-export([init/2]).

init(Req=#{method := <<"PUT">>}, _Opts) ->
  Req1 = proc:update(Req),
  {ok, Req1, #{}};
init(Req0=#{method := <<"GET">>}, _Opts) ->
  Req = proc:read(Req0),
  {ok, Req, #{}};
init(Req0, _Opts) ->
  Req = cowboy_req:reply(200,
                         #{<<"content-type">> => <<"application/json">>},
                         <<"i live like a worm.">>, Req0),
  {ok, Req, #{}}.

