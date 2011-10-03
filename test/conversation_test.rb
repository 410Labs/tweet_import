require 'helper'

class ConversationTest < Test::Unit::TestCase
  def setup
    @data = twitter_data
    @subject = TweetImport::Conversation.new
    stub(Twitter).status { |id| @data[id] }
    stub(@subject).twitter_search { |screen_name, first_id_str|
      @data.select { |id,status| status.text.include?("@#{screen_name}") }.select { |id,status| id.to_i >= first_id_str.to_i }.map { |id,status| status }
    }
  end
  
  def test_build_conversation_from_any_tweet_in_the_chain
    (1..@data.size).each do |id|
      @subject.lookup(id.to_s)
      assert_equal @data.size, @subject.statuses.size
      assert_equal 6, @subject.users.size
      assert_equal 6, @subject.user_ids.size
    end
  end

  def test_build_conversation_from_an_unknown_tweet
    @subject.lookup('-1')
    assert_equal 0, @subject.statuses.size
    assert_equal 0, @subject.users.size
    assert_equal 0, @subject.user_ids.size
  end

  private
  
  #
  # 1 -> 2
  #   -> 3 -> 4 -> 6 -> 9 -> 10
  #   -> 5 -> 7 -> 8
  #
  def twitter_data(time=Time.now)
    h = {}
    h['1'] = Hashie::Mash.new :id_str => '1',   :in_reply_to_status_id_str => nil, :user => { :screen_name => 'aaa', :id_str => '1'}, :text => 'Initial tweet', :created_at => time
    h['2'] = Hashie::Mash.new :id_str => '2',   :in_reply_to_status_id_str => '1', :user => { :screen_name => 'bbb', :id_str => '2'}, :text => '@aaa i disagree', :created_at => time += 60
    h['3'] = Hashie::Mash.new :id_str => '3',   :in_reply_to_status_id_str => '1', :user => { :screen_name => 'ccc', :id_str => '3'}, :text => '@aaa i agree', :created_at => time += 60
    h['4'] = Hashie::Mash.new :id_str => '4',   :in_reply_to_status_id_str => '3', :user => { :screen_name => 'ddd', :id_str => '4'}, :text => '@ccc how can you agree?', :created_at => time += 60
    h['5'] = Hashie::Mash.new :id_str => '5',   :in_reply_to_status_id_str => '1', :user => { :screen_name => 'eee', :id_str => '5'}, :text => '@aaa who r u', :created_at => time += 60
    h['6'] = Hashie::Mash.new :id_str => '6',   :in_reply_to_status_id_str => '4', :user => { :screen_name => 'aaa', :id_str => '1'}, :text => '@ddd because i can', :created_at => time += 60
    h['7'] = Hashie::Mash.new :id_str => '7',   :in_reply_to_status_id_str => '5', :user => { :screen_name => 'aaa', :id_str => '1'}, :text => '@eee i am who i am', :created_at => time += 60
    h['8'] = Hashie::Mash.new :id_str => '8',   :in_reply_to_status_id_str => '7', :user => { :screen_name => 'eee', :id_str => '5'}, :text => '@aaa nice one popeye', :created_at => time += 60
    h['9'] = Hashie::Mash.new :id_str => '9',   :in_reply_to_status_id_str => '6', :user => { :screen_name => 'ddd', :id_str => '4'}, :text => '@eee you have that right', :created_at => time += 60
    h['10'] = Hashie::Mash.new :id_str => '10', :in_reply_to_status_id_str => '9', :user => { :screen_name => 'fff', :id_str => '6'}, :text => '@ddd wtf is all this?', :created_at => time += 60
    h
  end
  
end