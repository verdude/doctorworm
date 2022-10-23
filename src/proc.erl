-module(proc).
-behavior(gen_statem).

%% API.
-export([handle/1]).
-export([stop/0]).

%% gen_statem.
-export([callback_mode/0]).
-export([init/1]).
-export([terminate/3]).
-export([handle_event/4]).

-export([accepted/3]).
-export([authorized/3]).
-export([forbidden/3]).
-export([proceed/3]).

%% API.
handle(Req) ->
  case gen_statem:start({local, ?MODULE}, ?MODULE, Req, []) of
    {ok, _} -> flow();
    _ -> null
  end.

stop() ->
  gen_statem:stop({local, ?MODULE}).

%% gen_statem.

callback_mode() ->
  state_functions.

init(Req) ->
  {ok, accepted, Req}.

handle_event(_EventType, _EventData, StateName, StateData) ->
  {next_state, StateName, StateData}.

terminate(_Reason, _StateName, _StateData) ->
  ok.

%% machine.

accepted({call, From}, authenticate, Req) ->
  Auth = list_to_binary(os:getenv("DWORMKEY")),
  case Auth == cowboy_req:header(<<"authorization">>, Req) of
    true -> {next_state, proceed, Req, {reply, From, proceed}};
    false -> {next_state, forbidden, Req, {reply, From, forbidden}}
  end.

authorized({call, _From}, secrets, Req) ->
  Req1 = cowboy_req:reply(200, #{}, wow, Req),
  {next_state, proceed, Req1};
authorized({call, From}, _, Req) ->
  Req1 = cowboy_req:reply(200, Req),
  {stop_and_reply, normal, {reply, From, Req1}}.

forbidden({call, From}, bad, Req) ->
  Req1 = cowboy_req:reply(403, Req),
  {stop_and_reply, normal, {reply, From, Req1}}.

% TODO: save data in genserver
proceed({call, From}, proceed, Req) ->
  case cowboy_req:read_body(Req, #{length => 8192, period => 1000}) of
    {ok, _Data, _} -> stop_and_reply(From, 200, Req);
    {more, _, _} -> stop_and_reply(From, 403, Req)
  end.

%% internal

flow() ->
  case gen_statem:call(?MODULE, authenticate) of
    proceed -> gen_statem:call(?MODULE, proceed);
    forbidden -> gen_statem:call(?MODULE, bad)
  end.

stop_and_reply(From, StatusCode, Req) ->
  Req1 = cowboy_req:reply(StatusCode, Req),
  {stop_and_reply, normal, {reply, From, Req1}}.
