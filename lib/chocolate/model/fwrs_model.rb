require 'date'
require 'chocolate/model/model'

module Model

  class FwrsModel < Model

    def feature(id)
      statement = @data_source.prepare('SELECT * FROM feature WHERE id = ?')
      result = statement.execute(id)
    end

    # find future time fields from current system time
    #
    # @param [String]
    # @return [Mysql]
    def find(statement)
      now = DateTime.parse(Time.now.to_s).strftime('%Y-%m-%d %H:%M:%S')
      result = statement.execute
      return result
    end

    def find_feature
      now = DateTime.parse(Time.now.to_s).strftime('%Y-%m-%d %H:%M:%S')
      statement = @data_source.prepare("SELECT * FROM feature WHERE `from` >= '#{now}'")
      fields = statement.execute
      features = []
      fields.each_hash do |field|
        features << {:id => field['id'], :title => field['title'], :notice_date => [field['from'].to_s, field['session_from'].to_s]}
      end
      return features
    end

  end

end
