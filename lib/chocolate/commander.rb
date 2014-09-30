require 'singleton'
require 'chocolate/observer'
require 'chocolate/db_keeper'
require 'chocolate/model/fwrs_factory'
require 'chocolate/option'
require 'chocolate/chatwork_subject'
require 'chocolate/model_subject'

# Chocolate commander
class Commander < Observer
  include Singleton

  def initialize
    @chatwork_subject = ChatworkSubject.new
    @chatwork_subject.registerObserver(self)
    @model_subject = ModelSubject.new
    @db = DBKeeper.new
  end

  # Start a process
  def start
    #@model_subject.run
    @chatwork_subject.run
    @chatwork_subject.thread.join
    #@model_subject.thread.join
  end

  # Handles a message
  #
  # @param [ChatworkSubject]
  def update(chatwork)
    chatwork.messages.each do |message|
      options = Option.parse(message)
      if options.has_key?(:error)
        p options[:error]
      else
        do_command(options)
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
      list = @db.find(:notice_date)

      messages = []
      list.each_hash do |columns|
        id = columns['id'].to_s
        type = columns['type'].to_s
        name = columns['name'].to_s
        master_id = columns['master_id'].nil? ? '' : "(#{columns['master_id']})"
        notice_date = columns['notice_date']
        active = columns['active'] == 1 ? '*' : ' '
        as_task = columns['as_task'] == 1 ? 'T' : '  '
        messages << "#{active} #{as_task} #{master_id} #{name} #{notice_date}"
      end

    elsif command == 'add'
      if options[:n].nil? || !options.has_key?(:t) || !options.has_key?(:d)
          return 'Invalid parameters to add'
      end

      as_task = options.has_key?(:t) ? 1 : 0
      @db.create('user', options[:n], nil, 1, as_task, options[:d])

    elsif command == 'delold'
      @db.delete_old

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
      end

    elsif command == 'del'
      id = commands[:command][1]
      unless id.nil?
        @db.delete(id)
      end
    end
  end

end