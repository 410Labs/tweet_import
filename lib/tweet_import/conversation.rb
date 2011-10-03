require 'twitter'
require 'logger'

module TweetImport

  class Conversation
    include Utilities
    
    def initialize(options={})
      @statuses = []
      @tweet_cache = {}
      @search_cache = {}
      configure_logger(options)
      configure_twitter(options)
    end
    
    # Find all tweets that are part of the "conversation" including the given tweet id. Feel free to
    # pass a String, Number, or twitter.com url.
    def lookup(status_id_str)
      ingest(extract_tweet_id(status_id_str))
      @logger.debug "now we have the partial conversation, all the way up the original: #{first_id_str}"
      loop do
        @logger.debug "searching twitter for mentions of our users"
        count = users.inject(0) do |a,user|
          a + search_for_mentions(user.screen_name)
        end
        @logger.debug "saved #{count} tweets during that pass"
        break if count == 0
      end
      @logger.debug "all done. the conversation has #{@statuses.size} tweets amongst #{users.size} users"
      @statuses.sort! {|a,b| a.created_at <=> b.created_at }
    end
    
    def statuses
      @statuses
    end

    def users
      @statuses.map { |status| status.user }.uniq { |u| u.id_str }
    end

    def user_ids
      users.map { |u| u.id_str }
    end

    private

    # Pseudo-code:
    # start with a tweet. get it from the api
    # 1. save the current tweet
    # if it's in_reply_to_status_id_str
    # get that tweet
    # goto 1
    # now we have the partial conversation, all the way up the original
    # 3. now uniquely identify all the users involved so far
    # for each user
    # 2. is this a new user to us? search for their mentions since the original tweet
    # for each tweet found, hit the REST api to get the in_reply_to_status_id_str
    # for each tweet that is in reply to ANY of the tweets we've found so far, goto 1
    # goto 3 until no more tweets are found

    # Save a tweet if we have not seen it yet, recursively save the tweet it is in reply to.
    def ingest(status_id_str)
      counter = 0
      unless tracking? status_id_str
        @logger.debug "ingesting tweet #{status_id_str}"
        status = save tweet(status_id_str)
        counter += 1 if status
        if status && status.in_reply_to_status_id_str
          counter += ingest(status.in_reply_to_status_id_str)
        end
        @logger.debug "during that round, we saved #{counter} tweets"
      end
      counter
    end

    # Save all tweets mentioning the given user and are in reply to tweets we have kept.
    def search_for_mentions(screen_name)
      @logger.debug "search mentions of @#{screen_name}"
      counter = 0
      search(screen_name, first_id_str) do |status|
        if status && tracking?(status.in_reply_to_status_id_str)
          counter += ingest(status.id_str)
        end
      end
      @logger.debug "found #{counter} tweets referencing @#{screen_name}"
      counter
    end

    def first_id_str
      @first_id_str ||= @statuses.map { |status| status.id_str }.min
    end

    # Return true if we have saved this tweet.
    def tracking?(status_id_str)
      @statuses.map(&:id_str).include?(status_id_str)
    end
    
    def save(status)
      @logger.debug "saving tweet #{status}" if status
      @statuses << status if status
      status
    end

    # Yield each found tweet that matches.
    def search(screen_name, first_id_str)
      twitter_search(screen_name, first_id_str).each do |status|
        yield tweet(status.id_str)
      end
    end
    
    def configure_logger(options)
      if options[:logger]
        @logger = options[:logger]
      else
        @logger = Logger.new(options[:logfile] || '/dev/null')
        @logger.level = options[:loglevel] || Logger::DEBUG
        @logger.formatter = proc do |severity, datetime, progname, msg|
          "#{datetime.strftime('%Y-%m-%d %H:%M:%S')} #{severity}: #{msg}\n"
        end
      end
    end
    
    # Hit twitter.com for a tweet. Cached.
    def tweet(status_id_str)
      return nil if @tweet_cache[status_id_str] == 'x'
      @tweet_cache[status_id_str] ||= Twitter.status(status_id_str)
    rescue Twitter::NotFound, Twitter::Unauthorized, Twitter::Forbidden
      @tweet_cache[status_id_str] = 'x'
    end

    # Hit twitter.com to do a search. Cached.
    def twitter_search(screen_name, first_id_str)
      @search_cache["#{screen_name}-#{first_id_str}"] ||= Twitter::Search.new.mentioning(screen_name).no_retweets.since_id(first_id_str)
    end

    def configure_twitter(options={})
      Twitter.configure do |config|
        config.oauth_token = options[:oauth_token] if options[:oauth_token]
        config.oauth_token_secret = options[:oauth_token_secret] if options[:oauth_token_secret]
        config.consumer_key = options[:consumer_key] if options[:consumer_key]
        config.consumer_secret = options[:consumer_secret] if options[:consumer_secret]
      end
    end

  end
end
