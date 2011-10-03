# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)
 
require 'tweet_import/version'
 
Gem::Specification.new do |s|
  s.name        = "tweet_import"
  s.version     = TweetImport::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Jonathan Julian"]
  s.email       = ["jonathan@410labs.com"]
  s.homepage    = "http://github.com/410labs/tweet_import"
  s.summary     = "Import all related tweets to make a conversation"
  s.description = "TweetImport is a library that finds all tweets that comprise a conversation on Twitter. It will use the Twitter api to find all the tweets that have their references traced up to the original tweet."
 
  s.required_rubygems_version = ">= 1.3.6"
 
  s.files        = Dir.glob("{lib}/**/*") + %w(README.md)
  s.require_path = 'lib'
end