class Subject

  def initialize
    @observers = []
  end

  def registerObserver(observer)
    @observers << observer
  end

  def removeObserver
  end

  def notifyObservers
    @observers.each do |observer|
      observer.update(self)
    end
  end

end