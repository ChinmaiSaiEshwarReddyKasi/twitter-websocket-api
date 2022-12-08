%%%-------------------------------------------------------------------
%% @doc twitterapi public API
%% @end
%%%-------------------------------------------------------------------

-module(twitterapi_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    twitterapi_sup:start_link().

stop(_State) ->
    ok.

%% internal functions
