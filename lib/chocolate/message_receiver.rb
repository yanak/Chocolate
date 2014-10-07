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
      end
    end
  end

  private

  def retrieve_message
    messages = @chatwork.retrieve_messages

    messages.each do |message|
      p message
      if (message =~ /^choco/) == 0
        @messages = [raw_command.match(/^choco (.*)/)[1]]
        notifyObservers
      end
    end
  end

end