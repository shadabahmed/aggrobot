require_relative './sql_functions/common'

module Aggrobot
  module SQLFunctions

    autoload :MySQL,  File.expand_path('../sql_functions/mysql', __FILE__)
    autoload :PgSQL, File.expand_path('../sql_functions/pgsql', __FILE__)
    autoload :SQLite, File.expand_path('../sql_functions/sqlite', __FILE__)

    POSTGRES_ADAPTER_NAME = 'postgresql'
    SQLITE_ADAPTER_NAME = 'sqlite3'
    MYSQL_ADAPTER_NAME = 'mysql2'

    def self.setup(precision = 2, adapter = ActiveRecord::Base.configurations[Rails.env]['adapter'])
      extend Common
      adapter_module = case adapter
                         when POSTGRES_ADAPTER_NAME then PgSQL
                         when MYSQL_ADAPTER_NAME then MySQL
                         when SQLITE_ADAPTER_NAME then SQLite
                    else
                      raise Exception.new "Database adaptor not supported: #{ActiveRecord::Base.connection.adapter_name}"
                       end
      adapter_module.precision = precision
      extend adapter_module
    end

  end
end