-module(dworm_sup).
-behaviour(supervisor).

-export([start_link/0]).
-export([init/1]).

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init([]) ->
    Procs = [{state, {state, start_link, []}, permanent, brutal_kill, worker, [state]}],
    {ok, {{one_for_one, 1, 5}, Procs}}.
