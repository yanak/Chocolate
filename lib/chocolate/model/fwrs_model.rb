require 'date'
require 'chocolate/model/model'

module Model

  # Fwrs master model
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

    # Find features
    # @return [Array] {:id, :title, :notice}
    def find_feature
      now = DateTime.parse(Time.now.to_s).strftime('%Y-%m-%d %H:%M:%S')
      statement = @data_source.prepare("SELECT * FROM feature WHERE `from` >= '#{now}'")
      fields = statement.execute
      features = []
      fields.each_hash do |field|
        # Unique from and session_from date
        if field['from'] == field['session_from']
          date = DateTime.parse(field['from'].to_s).strftime('%Y-%m-%d %H:%M:%S')
          notice_date = [date]
        else
          date1 = DateTime.parse(field['from'].to_s).strftime('%Y-%m-%d %H:%M:%S')
          date2 = DateTime.parse(field['session_from'].to_s).strftime('%Y-%m-%d %H:%M:%S')
          notice_date = [date1, date2]
        end
        features << {master_id: field['id'], title: field['title'], notice_date: notice_date }
      end
      return features
    end

  end

end
