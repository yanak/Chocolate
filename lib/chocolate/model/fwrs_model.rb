require 'chocolate/model/model'

class FwrsModel < Model

  def feature(id)
    statement = @data_source.prepare('SELECT * FROM feature WHERE id = ?')
    result = statement.execute(id)
  end

  def close
    @data_source.close
  end

end
