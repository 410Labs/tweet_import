module TweetImport
  module Utilities

    def extract_tweet_id(tweet)
      return nil if tweet.nil?
      str = tweet.to_s
      return nil if '' == str.strip
      m = str.match /twitter.com\/(?:#!\/)?\w+\/status\/(\d+)/i
      m ? m[1] : str
    end

  end
end
