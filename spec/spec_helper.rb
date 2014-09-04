# Notice there is a .rspec file in the root folder. It defines rspec arguments

# Set Rails environment as test
ENV['RAILS_ENV'] = 'test'

# Ruby 1.9 uses simplecov. The ENV['COVERAGE'] is set when rake coverage is run in ruby 1.9
if ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.start do
    # Remove the spec folder from coverage. By default all code files are included. For more config options see
    # https://github.com/colszowka/simplecov
    add_filter File.expand_path('../../spec/', __FILE__)
    coverage_dir(ENV['COVERAGE'] == 'integration' ? 'coverage/integration' : 'coverage/unit')
  end
end

# Modify load path so you can require 'aggrobot' directly.
$LOAD_PATH.unshift(File.expand_path('../../lib', __FILE__))

require 'rubygems'
# Loads bundler setup tasks. Now if I run spec without installing gems then it would say gem not installed and
# do bundle install instead of ugly load error on require.
require 'bundler/setup'

# This will require me all the gems automatically for the groups.
Bundler.require(:default, :test)

require 'aggrobot'
require 'database_cleaner'
# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[File.join(File.dirname(__FILE__), 'support/**/*.rb')].each { |f| require f }

begin
  ActiveRecord::Base.configurations = {'test' => {'adapter' => 'sqlite3',
                                                  'database' => ':memory:',
                                                  'min_messages' => 'warning'}}
  ActiveRecord::Base.establish_connection
  connection = ActiveRecord::Base.connection
  connection.execute("SELECT 1")
rescue
  at_exit do
    puts "-" * 80
    puts "Unable to connect to database. Make sure you the the necessary libraries for sqlite installed"
    puts "-" * 80
  end
  raise $!
end

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus

  config.include FactoryGirl::Syntax::Methods

  connection = ActiveRecord::Base.connection

  config.after(:all) do
    User.delete_all
  end

  config.before(:suite) do
  begin

    connection.create_table :users do |t|
      t.text    :name
      t.text    :country
      t.integer :age
      t.text    :gender
      t.date    :dob
      t.integer :score
    end

  end
    Aggrobot::SQLFunctions.setup

  end

  config.after(:suite) do
    #connection.drop_table :users
  end

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random'
end


