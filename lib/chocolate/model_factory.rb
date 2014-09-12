require 'chocolate/model/fwrs_model'
require 'chocolate/model/factory'
require 'chocolate/sy_config'
require 'mysql'

class ModelFactory < Factory

  def noticeable
    return true
  end

  private

  def get_data_source
    config = SyConfig.new('database').load
    return Mysql::new(config['host'], config['user'], config['password'], config['db_name'])
  end

end