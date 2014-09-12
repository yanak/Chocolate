require 'chocolate/model/fwrs_model'
require 'chocolate/sy_config'
require 'mysql'

class ModelFactory

    def create_fwrs_dao
      return FwrsModel.new(get_data_source)
    end

    private

    def get_data_source
      config = SyConfig.new('database').load
      return Mysql::new(config['host'], config['user'], config['password'], config['db_name'])
    end

end