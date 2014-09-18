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
    @model_subject.run
    @chatwork_subject.run
    @model_subject.thread.join
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
  def do_command(options)
    command = options[:command].first
    options = options[:options]
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
      as_task = options.has_key?(:t) ? 1 : 0
      @db.create('user', options[:n], nil, 1, as_task, options[:d])
    elsif command == 'delete'
      @db.delete_old
    elsif command == 'mod'
    end
  end

end