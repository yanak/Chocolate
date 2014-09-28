require 'chocolate/chatwork'

class ChatworkKeeper

  def initialize
    @chatwork = Chatwork.new
  end

  def retrieve_message
    return @chatwork.retrieve_messages(10)
  end

  def create_message(message)
    @chatwork.create_message(message)
  end

end