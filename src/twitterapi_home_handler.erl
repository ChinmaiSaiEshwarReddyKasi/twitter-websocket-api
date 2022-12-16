-module(twitterapi_home_handler).
-export([init/2]).

init(Req, State) ->
    Dir = element(2, file:get_cwd()) ++ "/priv/home.html",
    FileSize=filelib:file_size(Dir),
    Resp = cowboy_req:reply(200, #{<<"Content-Type">> => <<"text/html">>}, {sendfile, 0, FileSize, Dir}, Req),
    {ok, Resp, State}.