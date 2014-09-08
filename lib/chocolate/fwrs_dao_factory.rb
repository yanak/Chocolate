require 'chocolate/model/fwrs_db_dao'
require 'mysql'

class FwrsDaoFactory

  class << self
    def create_fwrs_dao
      return FwrsDbDao.new(get_data_source)
    end

    private

    def get_data_source
      # TODO get settings from yaml
      return Mysql::new()
    end
  end

end