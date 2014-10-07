require 'chocolate/sy_config'
require 'net/https'
require 'zlib'
require 'uri'
require 'json'
require 'singleton'

class Chatwork
  include Singleton

  def initialize
    @base_url = 'kcw.kddi.ne.jp'
    @login_url = ''
    @get_url = 'gateway.php'
    @account = ''
    @mail = ''
    @password = ''
    @cookie_ = ''
    @access_token_ = ''
    @https_ = create_https(@base_url)
    @api_https_ = create_https('api.chatwork.com')
    @user_info = SyConfig.new('user_info').load
    @members = SyConfig.new('members').load

    @post_header_ = {
        'Accept' => 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
        'Accept-Encoding' => 'gzip,deflate',
        'Accept-Language' => 'ja,en-US;q=0.8',
        'Cache-Control' => 'no-cache',
        'Content-Type' => 'application/x-www-form-urlencoded',
        'Pragma' => 'no-cache',
        'Origin' => 'https://kcw.kddi.ne.jp',
        'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/37.0.2062.94 Safari/537.36',
    }

    @get_header_ = {
        'Accept' => 'application/json, text/javascript, */*; q=0.01',
        'Accept-Encoding' => 'gzip,deflate,sdch',
        'Accept-Language' => 'ja,en-US;q=0.8',
        'Cache-Control' => 'no-cache',
        'Pragma' => 'no-cache',
        'Referer' => 'https://kcw.kddi.ne.jp/',
        'Content-Type' => 'text/html; charset=utf-8',
        'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/37.0.2062.94 Safari/537\'.36',
        #'X-NewRelic-ID' => 'VwYDUFBbGwEIUVFUAwE=',
        #'X-Requested-With' => 'XMLHttpRequest',
    }

    @api_header_ = {
        'X-ChatWorkToken' => @user_info['api_token']
    }

    @get_header_['Cookie'] = get_cookie

    token_and_myid = get_token_and_myid
    @access_token_ = token_and_myid[:token]
    @myid = token_and_myid[:myid]

  end

  # Retrieves messages in chat room
  #
  # @param from [Integer] the retrieve second that between a latest message and old messages
  # @return [Array] containing messages as Hash
  def retrieve_messages(from = 10)
    uri = "/#{@get_url}?#{get_query_string}"
    lists = []
    @https_.start do
      body = @https_.get(uri, @get_header_).body
      StringIO.open(body, 'rb') do |sio|
        content = Zlib::GzipReader.wrap(sio).read
        lists = JSON.load(content)['result']['chat_list']
      end
    end

    new_message = []
    lists.each do |list|
      if list['tm'] >= Time.now.to_i - 10
        new_message << list
      end
    end

    return new_message
  end

  # Creates a message
  #
  # @param message [String]
  # @return [String] status code
  def create_message(message)
    uri = "/v1/rooms/#{@user_info['room_id']}/messages?body=#{URI.encode(message)}"
    response = ''
    @api_https_.start do
      response = @api_https_.post(uri, '', @api_header_)
    end

    return response.code
  end

  # Notify a event to specific users who are defined by system configuration
  #
  # @param message [String]
  # @return status code [String]
  def send_message_to_members(message)
    response = ''
    to_list = @members.map do |member|
      '[To:' + member.to_s + ']'
    end.join()
    uri = URI.encode("/v1/rooms/#{@user_info['room_id']}/messages?body=#{to_list}\n#{message}")

    @api_https_.start do
      response = @api_https_.post(uri, '', @api_header_)
    end
  end

  def set_task_to_members(message)
    response = ''
    to_list = @members.join(',')
    uri = URI.encode("/v1/rooms/#{@user_info['room_id']}/tasks?body=#{message}&to_ids=#{to_list}")

    @api_https_.start do
      response = @api_https_.post(uri, '', @api_header_)
    end
  end

  private

  def create_https(base_url)
    https = Net::HTTP.new(base_url, 443)
    https.use_ssl = true
    https.ca_file = File.expand_path('../../../ca/cacert.pem', __FILE__)
    https.verify_mode = OpenSSL::SSL::VERIFY_PEER
    https.verify_depth = 5

    return https
  end

  def get_cookie
    return @get_header_['Cookie'] if @get_header_.has_key?('Cookie')

    response = ''
    @https_.start do
      #response = @https_.post("/login.php?lang=ja&s=#{@user_info['company']}", "email=#{@user_info['email']}&password=#{@user_info['password']}&login=%E3%83%AD%E3%82%B0%E3%82%A4%E3%83%B3", @post_header_)
      response = @https_.post("/login.php?#{login_query_string}", login_post_body, @post_header_)
    end

    fields = response.get_fields('Set-Cookie').map do |field|
      /(cwssid=\w+|AWSELB=\w+)/.match(field)[1]
    end

    sessions = []
    fields.uniq.each do |field|
      kv = field.split('=')
      sessions << {kv[0] => kv[1]}
    end

    cwssid = ''
    awselb = ''
    sessions.each do |session|
      session.each do |key, value|
        if key == 'cwssid'
          cwssid = key + '=' + value + ';'
        elsif key == 'AWSELB'
          awselb = key + '=' + value + ';'
        end
      end
    end
    cookie = cwssid + ' ' + awselb

    return cookie
  end

  def get_token_and_myid
    return @access_token_ unless @access_token_.empty?

    token = ''
    myid = ''
    @https_.start do
      body = @https_.get('/', @get_header_).body
      StringIO.open(body, 'rb') do |sio|
        content = Zlib::GzipReader.wrap(sio).read
        token = /ACCESS_TOKEN = '(\w+)'/.match(content)[1]
        myid = /myid = '(\d+)'/.match(content)[1]
      end
    end

    return { token: token,
             myid: myid,
    }
  end

  def get_query_string
    query = {
        :cmd => 'load_chat',
        :myid => @myid,
        :_v => '1.80a',
        :_av => 4,
        :_t => @access_token_,
        :ln => 'ja',
        :room_id => @user_info['room_id'],
        :last_chat_id => 0,
        :first_chat_id => 0,
        :jump_to_chat_id => 0,
        :unread_num => 0,
        :file => 1,
        :task => 1,
        :desc => 1,
        :_ => 1409976119945,
    }

    parameter = query.map do |k,v|
      URI.encode(k.to_s) + '=' + URI.encode(v.to_s)
    end.join('&')

    return parameter
  end

  def login_query_string
    query = {
        :lang => 'ja',
        :s => @user_info['company'],
    }

    parameter = query.map do |k,v|
      URI.encode(k.to_s) + '=' + URI.encode(v.to_s)
    end.join('&')

    return parameter
  end

  def login_post_body
    body = {
        :email => @user_info['email'],
        :password => @user_info['password'],
        :login => 'ログイン',
    }

    parameter = body.map do |k,v|
      URI.encode(k.to_s) + '=' + URI.encode(v.to_s)
    end.join('&')

    return parameter
  end

end

