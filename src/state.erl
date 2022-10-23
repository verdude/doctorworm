-module(state).
-behaviour(gen_server).

%% API.
-export([start_link/0]).
-export([write/1]).
-export([read/1]).

%% gen_server.
-export([init/1]).
-export([handle_call/3]).
-export([handle_cast/2]).
-export([handle_info/2]).
-export([terminate/2]).
-export([code_change/3]).

%% API.

-spec start_link() -> {ok, pid()}.
start_link() ->
  gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

write(Data) -> gen_server:cast(?MODULE, {update, Data}).
read(secrets) -> gen_server:call(?MODULE, secrets).

%% gen_server.

init([]) ->
  {ok, <<"">>}.

handle_call(secrets, _From, State) ->
  {reply, State, State}.

handle_cast({update, Data}, _) ->
  logger:notice(Data),
  {noreply, Data}.

handle_info(_Info, State) ->
  {noreply, State}.

terminate(_Reason, _State) ->
  ok.

code_change(_OldVsn, State, _Extra) ->
  {ok, State}.
