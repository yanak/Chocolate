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

end