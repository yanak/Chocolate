require 'chocolate/subject'
require 'chocolate/db_keeper'
require 'chocolate/model/fwrs_factory'

class DbUpdater < Subject

  attr_reader :thread

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
    master.close

    # insert rows if master_id does not exist
    # update rows if master_id exist
    db = DBKeeper.new
    features.each do |feature|
      rows = db.find_by_master_id(feature[:master_id])
      feature[:notice_date].each do |notice_date|
        row = rows.shift
        if row.nil?
          db.create('feature', feature[:title], feature[:master_id], 1, 0, notice_date)
        else
          db.update(row['id'], feature[:title], notice_date)
        end
      end
    end
    db.close
  end

end