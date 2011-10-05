require 'helper'

class UtilitiesTest < Test::Unit::TestCase
  include TweetImport::Utilities

  def test_tweet_id_is_pulled_from_a_url
    assert_equal '118745990760103936', extract_tweet_id('https://twitter.com/#!/jonathanjulian/status/118745990760103936')
  end
  def test_tweet_id_is_pulled_from_an_old_url
    assert_equal '118745990760103936', extract_tweet_id('https://twitter.com/jonathanjulian/status/118745990760103936')
  end
  def test_tweet_id_is_pulled_from_a_no_scheme_url
    assert_equal '118745990760103936', extract_tweet_id('twitter.com/jonathanjulian/status/118745990760103936')
  end
  def test_tweet_id_is_returned_untouched
    assert_equal '118745990760103936', extract_tweet_id('118745990760103936')
  end
  def test_tweet_id_is_returned_even_if_its_passed_as_a_number
    assert_equal '118745990760103936', extract_tweet_id(118745990760103936)
  end
  def test_nil_is_handled
    assert_equal nil, extract_tweet_id(nil)
  end
  def test_blank_is_handled
    assert_equal nil, extract_tweet_id('')
    assert_equal nil, extract_tweet_id(' ')
  end
end
