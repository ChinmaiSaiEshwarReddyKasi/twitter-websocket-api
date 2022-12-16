-module(twitterapi_logout_handler).
-export([init/2]).

init(Req, State) ->
    {ok, _Data, Req0} = cowboy_req:read_body(Req),
    Username = maps:get(qs, Req0),
    NewReq = cowboy_req:reply(
        302,
        #{<<"location">> => <<"http://localhost:8080/">>},
        Req0
    ),
    twitterapi_server:logout(Username),
    {ok, NewReq, State}.