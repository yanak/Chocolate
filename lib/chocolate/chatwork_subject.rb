require 'chocolate/subject'
require 'chocolate/chatwork'

class ChatworkSubject < Subject

  attr_accessor :messages, :thread

  def initialize
    super
    @messages = nil
    @chatwork = Chatwork.new
  end

  def run
    @thread = Thread.start do
      while(true)
        retrieve_message
      end
    end


    # TODO Observe Chatwork
    # TODO Delete the command-prefix-word is "choco"
    #raw_command = 'choco add -n いつものイベント -d 2014-03-09 10:00:00 -t on'
    #raw_command = 'choco list -n いつものイベント -d 2014-03-09 10:00:00 -t on'
    #raw_command = 'choco delete'
    #raw_command = 'choco mod 302 -t on -a on -d 2014-10-09 10:00:00'
    raw_command = 'choco mod 302 -n pero8 -d 2014-10-09 10:00:00'
    #raw_command = 'choco mod 302 -t on'

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