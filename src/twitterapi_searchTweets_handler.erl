-module(twitterapi_searchTweets_handler).
-export([init/2]).

init(Req, State) ->
    {ok, Data, Req0} = cowboy_req:read_body(Req),
    Hashtag = parse_data(lists:nth(2, string:split(Data, "="))),
    Username = maps:get(qs, Req0),
    twitterapi_server:search_tweets(Username, Hashtag),
    {ok, Req0, State}.

parse_data(Data) ->
    Data1 = string:replace(binary_to_list(Data), "%40", "@", all),
    Data2 = string:replace(Data1, "%23", "#", all),
    Data3 = string:replace(Data2, "+", " ", all),
    list_to_binary(Data3).
