-module(twitterapi_server).
-behaviour(gen_server).

% Server Functions
-export([start_link/0]).
-export([register/1]).
-export([update_pid/2]).

% gen_server
-export([init/1]).
-export([handle_call/3]).
-export([handle_cast/2]).
-export([handle_info/2]).
-export([terminate/2]).
-export([code_change/3]).


% Server Functions
start_link() ->
	gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

register(Data) ->
    gen_server:cast(twitterapi_server, {register, Data}).

update_pid(Username, Pid) ->
    gen_server:cast(twitterapi_server, {updatePid, Username, Pid}).

% gen_server
init([]) ->
    process_flag(trap_exit, true),
    {ok, []}.

handle_call(_Req, _From, State) ->
    {reply, i_know, State}.

handle_cast({register, UserData}, State) ->
    insertIntoUserTable(maps:get(<<"Username">>, UserData), UserData),
    io:format("User data: ~p~n", [getUserData(maps:get(<<"Username">>, UserData))]),
    {noreply, State};
handle_cast({updatePid, Username, Pid}, State) ->
    Uname = list_to_binary(Username),
    UserData = getUserData(Uname),
    UpdatedData = maps:update(<<"UserPid">>, Pid, UserData),
    insertIntoUserTable(Uname, UpdatedData),
    % io:format("New User data: ~p~n", [getUserData(maps:get(<<"Username">>, UserData))]),
    Feed = maps:get(<<"Feed">>, UpdatedData),
    Tweets = maps:get(<<"Tweets">>, UpdatedData),
    Mentions = maps:get(<<"Mentions">>, UpdatedData),
    WebsocketData = #{
        <<"Feed">> => Feed,
        <<"Tweets">> => Tweets,
        <<"Mentions">> => Mentions
    },
    timer:sleep(500),
    Pid ! {wsMsg, WebsocketData},
    {noreply, State}.

handle_info(_Info, State) ->
	{noreply, State}.

terminate(_Reason, _State) ->
	ok.

code_change(_OldVsn, State, _Extra) ->
	{ok, State}.


% Util functions
getUserData(Username) ->
    element(2, 
        lists:nth(1, 
            ets:lookup(userTable, Username)
        )
    ).

insertIntoUserTable(Username, Data) ->
    ets:insert(userTable, {Username, Data}).