-module(twitterapi_server).
-behaviour(gen_server).

% API Endpoints
-export([start_link/0]).
-export([register/1]).
-export([update_pid/2]).
-export([subscribe/2]).
-export([create_tweet/2]).
-export([re_tweet/2]).
-export([search_tweets/2]).
-export([logout/1]).

% Server Functions
-export([init/1]).
-export([handle_call/3]).
-export([handle_cast/2]).
-export([handle_info/2]).
-export([terminate/2]).
-export([code_change/3]).


% API Endpoints
start_link() ->
	gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

register(Data) ->
    gen_server:cast(twitterapi_server, {register, Data}).

update_pid(Username, Pid) ->
    gen_server:cast(twitterapi_server, {updatePid, Username, Pid}).

subscribe(SubscriberUsername, SubscriptionUsername) ->
    gen_server:cast(twitterapi_server, {subscribe, SubscriberUsername, SubscriptionUsername}).

create_tweet(Username, Tweet) ->
    gen_server:cast(twitterapi_server, {createTweet, Username, Tweet}).

re_tweet(Username, Tweet) ->
    gen_server:cast(twitterapi_server, {createTweet, Username, Tweet}).

search_tweets(Username, Hashtag) ->
    gen_server:cast(twitterapi_server, {searchTweets, Username, Hashtag}).

logout(Username) ->
    gen_server:cast(twitterapi_server, {logout, Username}).

% Server Functions
init([]) ->
    process_flag(trap_exit, true),
    {ok, []}.

handle_call(_Req, _From, State) ->
    {reply, i_know, State}.

handle_cast({register, UserData}, State) ->
    insertIntoUserTable(maps:get(<<"Username">>, UserData), UserData),
    % io:format("User data: ~p~n", [getUserData(maps:get(<<"Username">>, UserData))]),
    {noreply, State};

handle_cast({updatePid, Username, Pid}, State) ->
    Uname = list_to_binary(Username),
    UserData = getUserData(Uname),
    UpdatedData = maps:update(<<"UserPid">>, Pid, UserData),
    insertIntoUserTable(Uname, UpdatedData),
    % io:format("New User data: ~p~n", [getUserData(maps:get(<<"Username">>, UserData))]),
    timer:sleep(500),
    sendMyData(Uname),
    {noreply, State};

handle_cast({subscribe, SubscriberUsername, SubscriptionUsername}, State) ->
    SubscriberUserData = getUserData(SubscriberUsername),
    SubscriptionUserData = getUserData(SubscriptionUsername),

    Data1 = maps:update(<<"Subscribers">>, maps:get(<<"Subscribers">>, SubscriptionUserData) ++ [SubscriberUsername], SubscriptionUserData),
    Data2 = maps:update(<<"Subscriptions">>, maps:get(<<"Subscriptions">>, SubscriberUserData) ++ [SubscriptionUsername], SubscriberUserData),

    % io:format("Old sub data: ~p~n New Sub Data: ~p~n Old Subs Data: ~p~n New Subs Data: ~p~n", [SubscriberUserData, Data2, SubscriptionUserData, Data1]),

    insertIntoUserTable(SubscriberUsername, Data2),
    insertIntoUserTable(SubscriptionUsername, Data1),

    timer:sleep(40),

    sendMyData(SubscriberUsername),
    sendMyData(SubscriptionUsername),
    {noreply, State};

handle_cast({createTweet, Username, Tweet}, State) ->    
    UserData = getUserData(Username),
    HasMention = lists:member(hd("@"), binary_to_list(Tweet)),
    HasHastag = lists:member(hd("#"), binary_to_list(Tweet)),

    UpdatedTweets = maps:update(<<"Tweets">>, maps:get(<<"Tweets">>, UserData) ++ [Tweet], UserData),
    insertIntoUserTable(Username, UpdatedTweets),
    timer:sleep(5),
    sendMyData(Username),

    SubscribersData = maps:get(<<"Subscribers">>, UpdatedTweets),
    lists:foreach(
        fun(Uname) ->
            FeedData = getUserData(Uname),
            UserPid = maps:get(<<"UserPid">>, FeedData),

            if(UserPid =:= undefined) ->
                io:format("Server: User with username ~p is disconnected!! Live updates about the tweet cannot be provided.~n", [Uname]),
                UpdatedFeedData = maps:update(<<"Feed">>, maps:get(<<"Feed">>, FeedData) ++ [Tweet], FeedData),
                insertIntoUserTable(Uname, UpdatedFeedData);
            true ->
                UpdatedFeedData = maps:update(<<"Feed">>, maps:get(<<"Feed">>, FeedData) ++ [Tweet], FeedData),
                insertIntoUserTable(Uname, UpdatedFeedData),
                sendMyData(Uname)
            end,
            timer:sleep(5)
        end,
        SubscribersData
    ),

    if(HasMention) ->
        MentionUsername = list_to_binary(string:substr(lists:nth(1, string:split(string:find(binary_to_list(Tweet), "@"), " ")), 2)),
        UpdatedData = maps:update(<<"Mentions">>, maps:get(<<"Mentions">>, getUserData(MentionUsername)) ++ [Tweet], getUserData(MentionUsername)),

        insertIntoUserTable(MentionUsername, UpdatedData),
        timer:sleep(5),
        
        UserPid = maps:get(<<"UserPid">>, UpdatedData),
        if(UserPid =:= undefined) ->
            ok;
        true ->
            sendMyData(MentionUsername)
        end;
    true ->
        ok
    end,

    if(HasHastag) ->
        Hashtag = list_to_binary(lists:nth(1, string:split(string:find(binary_to_list(Tweet), "#"), " "))),
        insertIntoHastagTable(Tweet, Hashtag);
    true ->
        ok
    end,
    {noreply, State};

handle_cast({searchTweets, Username, Hashtag}, State) ->
    UserData = getUserData(Username),
    UserPid = maps:get(<<"UserPid">>, UserData),
    HashtagData = getHashtagData(Hashtag),
    WebsocketData = #{
        <<"HashtagData">> => HashtagData,
        <<"Type">> => <<"Search">>
    },
    UserPid ! {wsMsg, WebsocketData},
    {noreply, State};

handle_cast({logout, Username}, State) ->
    UserData = getUserData(Username),
    UpdatedData = maps:update(<<"UserPid">>, undefined, UserData),
    insertIntoUserTable(Username, UpdatedData),
    timer:sleep(5),
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
getHashtagData(Hashtag) ->
    Data = ets:lookup(hashtagTable, Hashtag),
    if(Data /= []) ->
        Result = element(2, lists:nth(1, Data));
    true ->
        Result = []
    end,
    Result.

insertIntoUserTable(Username, Data) ->
    ets:insert(userTable, {Username, Data}).

insertIntoHastagTable(Tweet, Hashtag) ->
    ets:insert(hashtagTable, {Hashtag, getHashtagData(Hashtag) ++ [Tweet]}).

sendMyData(Username) ->
    UserData = getUserData(Username),
    Pid = maps:get(<<"UserPid">>, UserData),
    Feed = maps:get(<<"Feed">>, UserData),
    Tweets = maps:get(<<"Tweets">>, UserData),
    Mentions = maps:get(<<"Mentions">>, UserData),
    Subscribers = maps:get(<<"Subscribers">>, UserData),
    Subscriptions = maps:get(<<"Subscriptions">>, UserData),
    WebsocketData = #{
        <<"Feed">> => lists:reverse(Feed),
        <<"Tweets">> => lists:reverse(Tweets),
        <<"Mentions">> => lists:reverse(Mentions),
        <<"Subscribers">> => Subscribers,
        <<"Subscriptions">> => Subscriptions,
        <<"Type">> => <<"Profile">>
    },
    Pid ! {wsMsg, WebsocketData}.