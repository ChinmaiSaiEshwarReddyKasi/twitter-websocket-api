%%%-------------------------------------------------------------------
%% @doc twitterapi public API
%% @end
%%%-------------------------------------------------------------------

-module(twitterapi_app).

-behaviour(application).

-export([start/2, stop/1, setupDatabase/0]).

-define(ANY_HOST, '_').
-define(NO_OPTIONS, []).

start(_StartType, _StartArgs) ->
    Paths = [
        {"/", twitterapi_home_handler, ?NO_OPTIONS},
        {"/login", twitterapi_login_handler, ?NO_OPTIONS},
        {"/register", twitterapi_register_handler, ?NO_OPTIONS},
        {"/signUp", twitterapi_signUp_handler, ?NO_OPTIONS},
        {"/websocket", twitterapi_websocket_handler, ?NO_OPTIONS},
        {"/profile/:user", twitterapi_profile_handler, ?NO_OPTIONS},
        {"/tweet", twitterapi_tweet_handler, ?NO_OPTIONS},
        {"/retweet", twitterapi_retweet_handler, ?NO_OPTIONS},
        {"/subscribe", twitterapi_subscribe_handler, ?NO_OPTIONS},
        {"/searchTweets", twitterapi_searchTweets_handler, ?NO_OPTIONS},
        {"/logout", twitterapi_logout_handler, ?NO_OPTIONS},
        {"/css/[...]", cowboy_static, {priv_dir, twitterapi, "css"}},
        {"/js/[...]", cowboy_static, {priv_dir, twitterapi, "js"}}],

    Routes = [{?ANY_HOST, Paths}],

    setupDatabase(),
    Dispatch = cowboy_router:compile(Routes),
    {ok, _} = cowboy:start_clear(http_listener, [{port, 8080}], #{env => #{dispatch => Dispatch}}),
    twitterapi_sup:start_link().

stop(_State) ->
    ok.

%% internal functions

setupDatabase() ->
    checkTableStatus(),
    ets:new(hashtagTable, [set, named_table, public]),
    ets:new(userTable, [set, named_table, public]).

checkTableStatus() ->
    ServerTable = ets:whereis(hashtagTable),
    UserTable = ets:whereis(userTable),

    if(ServerTable /= undefined) ->
        ets:delete(hashtagTable);
    true -> 
        ok
    end,

    if(UserTable /= undefined) ->
        ets:delete(userTable);
    true -> 
        ok
    end.