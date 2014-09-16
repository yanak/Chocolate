require 'singleton'
require 'chocolate/observer'

class Commander < Observer
  include Singleton

  def initialize(subject)
    @subject = subject
  end

  def update
    # TODO DBKeeper
    # TODO
  end

  def start
  end

  def get_future_master
    master = Model::FwrsFactory.new.create
    features = master.find_future(:feature)

    features.each do |feature|
      p id = feature[0]
      p notice_date = feature[3].to_s
      p title = feature[7]
    end

    m.close
  end

end