-module(twitterapi_websocket_handler).
-export([init/2]).
-export([websocket_init/1]).
-export([websocket_handle/2]).
-export([websocket_info/2]).
-export([terminate/3]).

-define(HOUR, 60 * 60 * 1000).


init(Req, Opts) ->
    Username = binary_to_atom(maps:get(qs, Req)),
    Pid = maps:get(pid, Req),
    twitterapi_server:update_pid(atom_to_list(Username), Pid),
	{cowboy_websocket, Req, Opts, #{idle_timeout => ?HOUR}}.

websocket_init(State) ->
	{[], State}.

websocket_handle({text, Msg}, State) ->
	{[{text, << Msg/binary >>}], State};
websocket_handle(_Data, State) ->
	{[], State}.

websocket_info({wsMsg, Msg}, State) ->
	{[{text, jsone:encode(Msg)}], State};
websocket_info(_Info, State) ->
	{[], State}.

terminate(Reason, _Req, _State) ->
    io:format("~p~n",[Reason]),
    ok.