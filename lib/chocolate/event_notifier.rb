require 'chocolate/db_keeper'

class EventNotifier < Subject

  attr_reader :thread, :notifiable_events

  def initialize
    super
    @notifiable_events = []
  end

  def run
    @thread = Thread.start do
      while(true)
        notify
        sleep(5)
      end
    end
  end

  def notify
    db = DBKeeper.new

    # Notifies events to members
    notifiable_events = db.find_events

    unless notifiable_events.empty?
      @notifiable_events = notifiable_events

      notifiable_events.each do |event|
        # Deactivate a event
        #db.update_active(event['id'], 0)
      end

      notifyObservers
    end

    db.close
  end

end