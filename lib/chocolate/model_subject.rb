require 'chocolate/subject'
require 'chocolate/db_keeper'
require 'chocolate/model/fwrs_factory'

class ModelSubject < Subject

  attr_accessor :thread

  def initialize
    super
  end

  def run
    @thread = Thread.start do
      while(true)
        p 'update'
        update_feature
        p 'end update'
        sleep(3600)
      end
    end
  end

  private

  # Update feature
  def update_feature
    master = Model::FwrsFactory.new.create
    features = master.find_feature

    db = DBKeeper.new
    features.each do |f|

      # insert rows if master_id does not exist
      rows = db.find_by_master_id(f[:master_id])
      row = rows.next_hash
      if row.nil?
        f[:notice_date].size.times do |i|
          db.create('feature', f[:title], f[:master_id], 1, 0, f[:notice_date][i])
        end
      else
        f[:notice_date].size.times do |i|
          id = row['id']
          db.update(id, f[:title], f[:notice_date][i])
        end
      end
    end

    notifyObservers
  end

end