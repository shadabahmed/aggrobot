require 'rails/railtie'

module LogStasher
  class Railtie < Rails::Railtie
    config.aggrobot = ActiveSupport::OrderedOptions.new

    initializer :aggrobot do |app|
      Aggrobot.setup(app)
    end
  end
end