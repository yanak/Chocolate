require 'chocolate/model/fwrs_db'
require 'chocolate/sy_config'
require 'mysql'

class FwrsFactory

  class << self
    def create_fwrs
      return FwrsDb.new(get_data_source)
    end

    private

    def get_data_source
      config = load_db_config
      return Mysql::new(config['host'], config['user'], config['password'], config['db_name'])
    end

    def load_db_config
      return SyConfig.new('database').load
    end
  end

end