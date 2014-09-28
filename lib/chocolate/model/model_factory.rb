require 'chocolate/sy_config'
require 'mysql'

module Model

  class ModelFactory

    def initialize
      config = SyConfig.new('database').load
      mysql = Mysql::new(config['host'], config['user'], config['password'], config['db_name'])
      @data_source = mysql
    end

    def close
      @data_source.close
    end

    def noticeable
    end

    def ModelFactory.getFactory(app)
      begin
        factory = Object.const_get(app)
        return factory
      rescue NameError
        puts "undefined class: #{app}."
      end
    end

  end

end
