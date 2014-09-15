class Factory

  def initialize
    @data_source = get_data_source
  end

  def close
    @data_source.close
  end

  def get_data_source
  end

  def noticeable
  end

  def Factory.getFactory(klass)
    begin
      factory = Object.const_get(klass)
      return factory
    rescue NameError
      puts "undefined class: #{klass}."
    end
  end

end