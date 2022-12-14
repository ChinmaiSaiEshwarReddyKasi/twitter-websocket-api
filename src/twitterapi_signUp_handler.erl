-module(twitterapi_signUp_handler).
-import(project4, [generateProfile/4]).
-export([init/2]).

init(Req, State) ->
    {ok, Data, Req0} = cowboy_req:read_body(Req),
    % io:format("body ~p~n", [string:split(Data, "&", all)]),
    Body = string:split(binary_to_list(Data), "&", all),
    Email = lists:flatten(string:replace(lists:nth(2, string:split(lists:nth(1, Body), "=")), "%40", "@")),
    Username = lists:nth(2, string:split(lists:nth(2, Body), "=")),
    Password = lists:nth(2, string:split(lists:nth(3, Body), "=")),
    % io:format("new req ~p~p~p~n", [Email, Username, Password]),
    UserData = generateProfile(Email, Username, Password, ""),
    % io:format("supervisor data ~p~n",[supervisor:which_children(twitterapi_sup)]),
    % twitterapi_server:register(UserData),
    twitterServer ! {register, UserData},
    Location = list_to_binary("http://localhost:8080/profile/" ++ Username),
    NewReq = cowboy_req:reply(
        302,
        #{<<"location">> => Location},
        Req0),
    {ok, NewReq, State}.