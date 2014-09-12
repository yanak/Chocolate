# Model interface class.
class Model

  # @param [Mysql]
  def initialize(data_source)
    @data_source = data_source
  end

  # get feature info
  #
  # @param [int] feature id
  def noticeable(type)
  end

  def close
    @data_source.close
  end


end