-module(twitterapi_subscribe_handler).
-export([init/2]).

init(Req, State) ->
    {ok, Data, Req0} = cowboy_req:read_body(Req),
    SubscriptionUsername = lists:nth(2, string:split(Data, "=")),
    SubscriberUsername = maps:get(qs, Req0),
    twitterapi_server:subscribe(SubscriberUsername, SubscriptionUsername),
    {ok, Req0, State}.
