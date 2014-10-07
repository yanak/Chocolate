require 'chocolate/subject'
require 'chocolate/chatwork'

class MessageReceiver < Subject

  attr_accessor :messages, :thread

  def initialize
    super
    @messages = nil
    @chatwork = Chatwork.instance
  end

  def run
    @thread = Thread.start do
      while(true)
        retrieve_message
        sleep(5)
      end
    end
  end

  private

  def retrieve_message
    messages = @chatwork.retrieve_messages(5)

    messages.each do |message|
      if (message =~ /^choco/) == 0
        @messages = [message.match(/^choco (.*)/)[1]]
        notifyObservers
      end
    end
  end

end