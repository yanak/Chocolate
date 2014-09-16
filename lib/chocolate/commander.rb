require 'singleton'
require 'chocolate/observer'
require 'chocolate/db_keeper'
require 'chocolate/model/fwrs_factory'

class Commander < Observer
  include Singleton

  def initialize
    #@subject = subject
  end

  def update
    # TODO DBKeeper
    # TODO
  end

  def start
  end

  def get_future_master
    master = Model::FwrsFactory.new.create
    features = master.find_feature

    db = DBKeeper.new
    features.each do |f|
      f[:notice_date].size.times do |i|
        db.create('feature', f[:title], f[:id], 1, 0, f[:notice_date][i])
      end
    end
  end

end