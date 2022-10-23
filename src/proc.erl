-module(proc).
-behavior(gen_statem).

%% API.
-export([update/1]).
-export([read/1]).

%% gen_statem.
-export([callback_mode/0]).
-export([init/1]).
-export([terminate/3]).
-export([handle_event/4]).

-export([accepted/3]).
-export([forbidden/3]).
-export([authorized/3]).

%% API.
update(Req) ->
  case gen_statem:start({local, ?MODULE}, ?MODULE, Req, []) of
    {ok, _} -> flow(update);
    _ -> null
  end.

read(Req) ->
  case gen_statem:start({local, ?MODULE}, ?MODULE, Req, []) of
    {ok, _} -> flow(read);
    _ -> null
  end.

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
  authorize(Auth, From, Req).

forbidden({call, From}, _, Req) ->
  Req1 = cowboy_req:reply(403, Req),
  {stop_and_reply, normal, {reply, From, Req1}}.

authorized({call, From}, authorized, Req) ->
  case cowboy_req:read_body(Req, #{length => 8192, period => 1000}) of
    {ok, Data, _} ->
      gen_server:cast(state, {update, Data}),
      stop_and_reply(From, 200, Req);
    {more, _, _} -> stop_and_reply(From, 413, Req)
  end;
authorized({call, From}, read, Req) ->
  Data = gen_server:call(state, secrets),
  stop_and_reply(From, 200, Data, Req).

%% internal

flow(update) ->
  Status = gen_statem:call(?MODULE, authenticate),
  gen_statem:call(?MODULE, Status);
flow(read) ->
  Action = case gen_statem:call(?MODULE, authenticate) of
    authorized -> read;
    forbidden -> forbidden
  end,
  gen_statem:call(?MODULE, Action).

stop_and_reply(From, StatusCode, Req) ->
  Req1 = cowboy_req:reply(StatusCode, Req),
  {stop_and_reply, normal, {reply, From, Req1}}.
stop_and_reply(From, StatusCode, Data, Req) ->
  Req1 = cowboy_req:reply(StatusCode, #{}, Data, Req),
  {stop_and_reply, normal, {reply, From, Req1}}.

authorize(Auth, From, Req) when byte_size(Auth) > 0 ->
  case Auth == cowboy_req:header(<<"authorization">>, Req) of
    true -> {next_state, authorized, Req, {reply, From, authorized}};
    false -> {next_state, forbidden, Req, {reply, From, forbidden}}
  end;
authorize(_, From, Req) ->
  logger:emergency("authorization is not configured."),
  {next_state, forbidden, Req, {reply, From, forbidden}}.
