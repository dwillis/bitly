require 'test_helper'

class TestOAuth < Minitest::Test
  context "with a consumer" do
    setup do
      @consumer_token = 'token'
      @consumer_secret = 'secret'
      @consumer = Bitly::OAuth.new(@consumer_token, @consumer_secret)
    end

    should 'create the oauth client' do
      assert_kind_of OAuth2::Client, @consumer.client
    end

    should 'save the consumer details on the client' do
      assert_equal @consumer_token, @consumer.client.id
      assert_equal @consumer_secret, @consumer.client.secret
    end

    should 'get the oauth authorize url' do
      assert_match /https:\/\/bitly\.com\/oauth\/authorize\?.*client_id=#{@consumer_token}.*/, @consumer.authorize_url('http://test.local')
    end

    should 'get access token with code' do
      stub_request(:post, %r|https://api-ssl.bitly.com/oauth/access_token|).to_return({ :body => "access_token=token&login=hello&apiKey=API_KEY", :headers => { "Content-Type" => 'text/plain' }})
      access_token = @consumer.get_access_token_from_code('code', 'http://test.local')
      assert_kind_of OAuth2::AccessToken, access_token
      assert_equal @consumer.client, access_token.client
      assert_equal 'hello', access_token['login']
      assert_equal 'API_KEY', access_token['apiKey']
    end

    should 'get access token with access token' do
      access_token = @consumer.get_access_token_from_token('hello')
      assert_kind_of OAuth2::AccessToken, access_token
      assert_equal @consumer.client, access_token.client
    end

  end
end
