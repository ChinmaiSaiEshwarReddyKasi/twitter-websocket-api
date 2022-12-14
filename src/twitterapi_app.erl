%%%-------------------------------------------------------------------
%% @doc twitterapi public API
%% @end
%%%-------------------------------------------------------------------

-module(twitterapi_app).

-behaviour(application).

-import(project4, [checkTableStatus/0]).

-export([start/2, stop/1, startServer/0, setupDatabase/0]).

-define(ANY_HOST, '_').
-define(NO_OPTIONS, []).

start(_StartType, _StartArgs) ->
    % Paths = [
    %     {"/", cowboy_static, {priv_file, twitterapi, "home.html"}},
    %     {"/css/[...]", cowboy_static, {priv_dir, twitterapi, "css"}},
    %     {"/js/[...]", cowboy_static, {priv_dir, twitterapi, "js"}}
    % ],
    Paths = [
        {"/", twitterapi_home_handler, ?NO_OPTIONS},
        {"/register", twitterapi_register_handler, ?NO_OPTIONS},
        {"/signUp", twitterapi_signUp_handler, ?NO_OPTIONS},
        {"/websocket", twitterapi_websocket_handler, ?NO_OPTIONS},
        {"/profile/:user", twitterapi_profile_handler, ?NO_OPTIONS},
        {"/tweet", twitterapi_tweet_handler, ?NO_OPTIONS},
        {"/subscribe", twitterapi_subscribe_handler, ?NO_OPTIONS},
        {"/searchTweets", twitterapi_searchTweets_handler, ?NO_OPTIONS},
        {"/css/[...]", cowboy_static, {priv_dir, twitterapi, "css"}},
        {"/js/[...]", cowboy_static, {priv_dir, twitterapi, "js"}}],

    Routes = [{?ANY_HOST, Paths}],

    startServer(),
    setupDatabase(),
    Dispatch = cowboy_router:compile(Routes),
    {ok, _} = cowboy:start_clear(http_listener, [{port, 8080}], #{env => #{dispatch => Dispatch}}),
    twitterapi_sup:start_link().

stop(_State) ->
    ok.

%% internal functions

startServer() ->
    Pid = spawn(project4, server, []),
    register(twitterServer, Pid).

setupDatabase() ->
    checkTableStatus(),
    ets:new(hashtagTable, [set, named_table, public]),
    ets:new(userTable, [set, named_table, public]).
