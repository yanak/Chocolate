require 'chocolate/model/fwrs_db_dao'
require 'chocolate/sy_config'
require 'mysql'

class FwrsDaoFactory

  class << self
    def create_fwrs_dao
      return FwrsDbDao.new(get_data_source)
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