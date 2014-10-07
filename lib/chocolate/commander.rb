require 'singleton'
require 'chocolate/observer'
require 'chocolate/db_keeper'
require 'chocolate/model/fwrs_factory'
require 'chocolate/option'
require 'chocolate/message_receiver'
require 'chocolate/db_updater'
require 'chocolate/chatwork'
require 'chocolate/event_notifier'

# Chocolate commander
class Commander < Observer
  include Singleton

  def initialize
    @message_receiver = MessageReceiver.new
    @message_receiver.registerObserver(self)

    @db_updater = DbUpdater.new
    @db_updater.registerObserver(self)

    @event_notifier = EventNotifier.new
    @event_notifier.registerObserver(self)

    @db = DBKeeper.new
    @chatwork = Chatwork.instance
  end

  # Start a process
  def start
    @message_receiver.run
    @event_notifier.run
    @db_updater.run

    @db_updater.thread.join
    @event_notifier.thread.join
    @message_receiver.thread.join
  end

  # Handles a message
  #
  # @param [MessageReceiver]
  def update(chatwork)
    if chatwork.is_a?(EventNotifier)
      #events = @db_updater.notifiable_events
      events = @event_notifier.notifiable_events

      events.each do |event|
        message = <<-EOM
#{event['name']} が公開されました。
公開日時：#{event['notice_date']}
        EOM

        if event['as_task'] == 1
          @chatwork.set_task_to_members(message)
        else
          @chatwork.send_message_to_members(message)
        end
      end

    else
      chatwork.messages.each do |message|
        options = Option.parse(message)
        if options.has_key?(:error)
          # TODO should receive options[:error] as the argument
          do_command(:error)
        else
          do_command(options)
        end
      end
    end

  end

  private

  # Do a command that get it from ChatWork
  #
  # @param options [String]
  def do_command(commands)
    p commands
    command = commands[:command].first
    options = commands[:options]
    if command == 'list'
      events = @db.find(:notice_date)

      messages = []
      events.each do |row|
        id = row['id'].to_s
        type = row['type'].to_s
        name = row['name'].to_s
        master_id = row['master_id'].nil? ? '' : "(#{row['master_id']})"
        notice_date = row['notice_date']
        active = row['active'] == 1 ? '*' : ' '
        as_task = row['as_task'] == 1 ? 'T' : '  '
        messages << "#{active} #{as_task} #{master_id} #{name} #{notice_date}"
      end

      @chatwork.send_message(messages.join("\n"))

    elsif command == 'add'
      if options[:n].nil? || !options.has_key?(:t) || !options.has_key?(:d)
          return @chatwork.send_message('Invalid parameters to add')
      end

      as_task = options.has_key?(:t) ? 1 : 0
      @db.create('user', options[:n], nil, 1, as_task, options[:d])


      @chatwork.send_message('Register success!')

    elsif command == 'delold'
      @db.delete_old

      @chatwork.send_message('Delete Old success!')

    elsif command == 'mod'
      id = commands[:command][1]

      unless id.nil?
        # update a name and/or a notice_date?
        if !options[:n].nil? && !options[:d].nil?
          @db.update(id, options[:n], options[:d])
        elsif !options[:n].nil?
          @db.update(id, options[:n], nil)
        elsif !options[:d].nil?
          @db.update(id, nil, options[:d])
        end

        # update a task?
        if options[:t] == 'on'
          @db.update_as_task(id, 1)
        elsif options[:t] == 'off'
          @db.update_as_task(id, 0)
        end

        # update a active?
        if options[:a] == 'on'
          @db.update_active(id, 1)
        elsif options[:a] == 'off'
          @db.update_active(id, 0)
        end

        @chatwork.send_message('Modify success!')
      end

    elsif command == 'del'
      id = commands[:command][1]
      unless id.nil?
        @db.delete(id)
        @chatwork.send_message('Delete success!')
      end

    end
  end

end