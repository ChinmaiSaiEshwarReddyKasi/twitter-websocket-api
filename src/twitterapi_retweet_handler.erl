-module(twitterapi_retweet_handler).
-export([init/2]).

init(Req, State) ->
    {ok, Data, Req0} = cowboy_req:read_body(Req),
    Tweet = parse_data(lists:nth(2, string:split(Data, "="))),
    Username = maps:get(qs, Req0),
    twitterapi_server:re_tweet(Username, <<Username/binary, " retweeted: ", Tweet/binary>>),
    {ok, Req0, State}.

parse_data(Data) ->
    Data1 = string:replace(binary_to_list(Data), "%40", "@", all),
    Data2 = string:replace(Data1, "%23", "#", all),
    Data3 = string:replace(Data2, "+", " ", all),
    list_to_binary(Data3).
