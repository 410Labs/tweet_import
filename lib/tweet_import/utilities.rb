module TweetImport
  module Utilities

    def extract_tweet_id(str)
      return str.to_s unless str.respond_to?(:match)
      m = str.match /twitter.com\/(?:#!\/)?\w+\/status\/(\d+)/i
      m ? m[1] : str.to_s
    end

  end
end
