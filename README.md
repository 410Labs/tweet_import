# TweetImport

TweetImport is a library that finds all tweets that comprise a conversation on Twitter. It will use the Twitter api to find all the tweets that have their references traced up to the original tweet.

## Usage

Pass a tweet id, or a url of any tweet - it could the the first tweet in a conversation, or a reply at
any level down the chain. TweetImport will return to you all the tweets in the conversation.

Construct the import object:

    conversation = TweetImport::Conversation.new

Point it at a tweet. Each of the following is the same:

    conversation.lookup "https://twitter.com/#!/jonathanjulian/status/120905040935387136"

    conversation.lookup "120905040935387136"

    conversation.lookup 120905040935387136

Now you can peruse the tweets that make up the conversation:

    conversation.statuses.each { |status| puts status.text }

Note that future tweets might be part of this conversation. You'll have to track those on your own, using
the Twitter Streaming api. Hint: use `conversation.user_ids` to get a list of users you'll want to **follow**. See
the [Twitter Streaming API](https://dev.twitter.com/docs/streaming-api/methods).

## Developer notes

The code uses the Twitter REST api to quickly discover all tweets in the chain leading up to the original tweet.
It then issues a series of Twitter search requests for the screen_names of those involved in the conversation. Any
tweet that is in reply to one we've already kept is also saved. The search requests continue until we find no more
new tweets.

Tweets that are not marked "in\_reply\_to", or tweets that do not mention the user will not be found.

### Rate limiting and OAuth

Anonymous Twitter api requests have a lower rate-limit requests issued with oauth keys. Even though REST and Search api
requests are cached in the object, It is advised to pass your oauth keys during the construction of the object:

    conversation = TweetImport::Conversation.new({
      :oauth_token => 'your user token',
      :oauth_token_secret => 'your user secret',
      :consumer_key => 'your app key',
      :consumer_secret => 'your app secret'
    })

Call `Twitter.rate_limit_status` (twitter gem) to see the current number of requests remaining. If you are rate-limited, 
this object will raise Twitter::EnhanceYourCalm (as per the twitter gem).

### Logger

You can pass your own `:logger` in the options. Or you can configure the built-in logger's `:logfile` or `:loglevel`.


&copy; 2011 410 Labs