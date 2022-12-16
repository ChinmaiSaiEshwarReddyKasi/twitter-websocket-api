-module(twitterapi_signUp_handler).
-export([init/2]).

init(Req, State) ->
    {ok, Data, Req0} = cowboy_req:read_body(Req),
    Body = string:split(binary_to_list(Data), "&", all),
    Email = lists:flatten(string:replace(lists:nth(2, string:split(lists:nth(1, Body), "=")), "%40", "@")),
    Username = lists:nth(2, string:split(lists:nth(2, Body), "=")),
    Password = lists:nth(2, string:split(lists:nth(3, Body), "=")),
    UserData = generateProfile(Email, Username, Password, ""),
    twitterapi_server:register(UserData),
    Location = list_to_binary("http://localhost:8080/profile/" ++ Username),
    NewReq = cowboy_req:reply(
        302,
        #{<<"location">> => Location},
        Req0),
    {ok, NewReq, State}.

generateProfile(Email, UserName, Password, Pid) ->
    UserData = #{
        <<"Email">> => list_to_binary(Email),
        <<"Username">> => list_to_binary(UserName),
        <<"Password">> => list_to_binary(Password),
        <<"Tweets">> => [],
        <<"Subscribers">> => [],
        <<"Subscriptions">> => [],
        <<"Feed">> => [],
        <<"Mentions">> => [],
        <<"UserPid">> => Pid
    },
    UserData.