-module(twitterapi_websocket_handler).
-export([init/2]).
-export([websocket_init/1]).
-export([websocket_handle/2]).
-export([websocket_info/2]).
-export([terminate/3]).

-define(HOUR, 60 * 60 * 1000).


init(Req, Opts) ->
    % io:format("~p ws start~n",[self()]),
    % io:format("~p ws start pid~n",[binary_to_atom(maps:get(qs, Req))]),
    % io:format("~p ws start pid~n",[maps:get(pid, Req)]),
    Username = binary_to_atom(maps:get(qs, Req)),
    Pid = maps:get(pid, Req),
    twitterapi_server:update_pid(atom_to_list(Username), Pid),
    % twitterServer ! {updatePid, atom_to_list(Username), Pid},
    % register(Username, Pid),
	{cowboy_websocket, Req, Opts, #{idle_timeout => ?HOUR}}.

websocket_init(State) ->
    % io:format("~p ws init~n",[self()]),
    % eshwar ! {wsMsg, #{<<"hey">>=>[<<"hello">>, <<"hi">>]}},
	% erlang:start_timer(4000, self(), <<"Hello!">>),
	{[], State}.

websocket_handle({text, Msg}, State) ->
    io:format("~p handle1~n",[self()]),
	{[{text, << "That's what she said! ", Msg/binary >>}], State};
websocket_handle(_Data, State) ->
    io:format("handle2~n"),
	{[], State}.

websocket_info({wsMsg, Msg}, State) ->
	{[{text, jsone:encode(Msg)}], State};
websocket_info(_Info, State) ->
	{[], State}.

terminate(Reason, _Req, _State) ->
    io:format("~p~n",[Reason]),
    ok.