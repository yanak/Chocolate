require 'chocolate/model/fwrs'

class FwrsDb < Fwrs

  def feature(id)
    statement = @data_source.prepare('SELECT * FROM feature WHERE id = ?')
    result = statement.execute(id)
  end

  def close
    @data_source.close
  end

end
