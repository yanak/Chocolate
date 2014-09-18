require 'chocolate/subject'

class ChatworkSubject < Subject

  attr_accessor :messages

  def initialize
    super
    @messages = nil
  end

  def run
    # TODO Observe Chatwork
    # TODO Delete the command-prefix-word is "choco"
    #raw_command = 'choco add -n いつものイベント -d 2014-03-09 10:00:00 -t on'
    #raw_command = 'choco list -n いつものイベント -d 2014-03-09 10:00:00 -t on'
    raw_command = 'choco delete'

    if (raw_command =~ /^choco/) == 0
      @messages = [raw_command.match(/^choco (.*)/)[1]]
      notifyObservers
    end
  end

end