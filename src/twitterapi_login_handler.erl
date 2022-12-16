-module(twitterapi_login_handler).
-export([init/2]).

init(Req, State) ->
    {ok, Data, Req0} = cowboy_req:read_body(Req),
    Body = string:split(binary_to_list(Data), "&", all),
    Username = list_to_binary(lists:nth(2, string:split(lists:nth(1, Body), "="))),
    UserData = ets:lookup(userTable, Username),

    if(UserData /= []) ->
        Location = list_to_binary("http://localhost:8080/profile/" ++ binary_to_list(Username));
    true ->
        io:format("User not found"),
        Location = "http://localhost:8080/"
    end,

    NewReq = cowboy_req:reply(
        302,
        #{<<"location">> => Location},
        Req0),
    {ok, NewReq, State}.