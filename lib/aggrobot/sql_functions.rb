require_relative './sql_functions/common'

module Aggrobot
  class SQLFunctions
    DEFAULT_PRECISION = 2

    autoload :MySQL,  File.expand_path('../sql_functions/mysql', __FILE__)
    autoload :PgSQL, File.expand_path('../sql_functions/pgsql', __FILE__)
    autoload :SQLite, File.expand_path('../sql_functions/sqlite', __FILE__)

    POSTGRES_ADAPTER_NAME = 'postgresql'
    SQLITE_ADAPTER_NAME = 'sqlite3'
    MYSQL_ADAPTER_NAME = 'mysql2'

    def self.setup(precision, adapter = ActiveRecord::Base.configurations[Rails.env]['adapter'])
      precision ||= DEFAULT_PRECISION
      @precision = precision
      extend Common
      adapter_module = case adapter
                         when POSTGRES_ADAPTER_NAME then PgSQL
                         when MYSQL_ADAPTER_NAME then MySQL
                         when SQLITE_ADAPTER_NAME then SQLite
                    else
                      raise Exception.new "Database adaptor not supported: #{adapter}"
                    end
      extend adapter_module
    end

    def self.precision
      @precision
    end

  end
end