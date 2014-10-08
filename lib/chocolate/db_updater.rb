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
        update_feature
        sleep(3600)
      end
    end
  end

  private

  # Update feature
  def update_observation(table)
    master = Model::FwrsFactory.new.create
    obs = master.find_notifiable_observations(table)
    master.close

    # insert rows if master_id does not exist
    # update rows if master_id exist
    db = DBKeeper.new
    obs.each do |feature|
      rows = db.find_by_master_id(table, feature[:master_id])
      feature[:notice_date].each do |notice_date|
        row = rows.shift
        if row.nil?
          db.create('feature', feature[:title], feature[:master_id], 1, 0, notice_date)
        else
          db.update_master(row['id'], feature[:title], notice_date)
        end
      end
    end
    db.close
  end

end