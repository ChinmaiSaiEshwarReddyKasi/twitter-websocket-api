Twitter Websocket API
=====

As of now, Tweeter does not seem to support a WebSocket API. As part of this project, we built an engine that will be paired up with WebSockets to provide full functionality. 

Implemented a Twitter-like engine with the following functionality:
* Register account
* Send tweet. Tweets can have hashtags (e.g. #COP5615isgreat) and mentions (@bestuser)
* Subscribe to user's tweets
* Re-tweets (so that your subscribers get an interesting tweet you got by other means)
* Querying tweets subscribed to, tweets with specific hashtags, tweets in which the user is mentioned (my mentions)
* If the user is connected, deliver the above types of tweets live (without querying)

The goal of this project was to use the Cowboy Websocket framework to implement an Websocket interface that is a JSON based API which represents all the messages and their replies (including errors) for the Twitter API we created as part of Project 4.1.

Build
-----

    $ rebar3 compile

Run
----
    $ rebar3 shell
