# Be sure to restart your server when you modify this file

# Uncomment below to force Rails into production mode when
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.4' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.
  # See Rails::Configuration for more options.

  # Skip frameworks you're not going to use. To use Rails without a database
  # you must remove the Active Record framework.
  config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Specify gems that this application depends on.
  # They can then be installed with "rake gems:install" on new installations.
  # config.gem "bj"
  # config.gem "hpricot", :version => '0.6', :source => "http://code.whytheluckystiff.net"
  # config.gem "aws-s3", :lib => "aws/s3"
  config.gem 'rubycas-client', :version => '>= 2.1.0'

  # Only load the plugins named here, in the order given. By default, all plugins
  # in vendor/plugins are loaded in alphabetical order.
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Force all environments to use the same logger level
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Make Time.zone default to the specified zone, and make Active Record store time values
  # in the database in UTC, and return them converted to the specified local zone.
  # Run "rake -D time" for a list of tasks for finding time zone names. Comment line to use default local time.
  config.time_zone = 'UTC'

  # Your secret key for verifying cookie session data integrity.
  # If you change this key, all old sessions will become invalid!
  # Make sure the secret is at least 30 characters and all random,
  # no regular words or you'll be exposed to dictionary attacks.
  config.action_controller.session = {
    :session_key => '_cas_callback_session',
    :secret      => '623f6312ec0312002e14cb5078a24ca0ca5d6d3aef64c154594e3f946cdbcbd1849283f56c4d20afaebf3a2d2268dbec836516344e505177ad4656fabc5a63d5'
  }

  # Use the database for sessions instead of the cookie-based default,
  # which shouldn't be used to store highly confidential information
  # (create the session table with "rake db:sessions:create")
  # config.action_controller.session_store = :active_record_store

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector
end

require 'casclient'
require 'casclient/frameworks/rails/cas_proxy_callback_controller'
require 'casclient/frameworks/rails/filter'

cas_logger = CASClient::Logger.new(RAILS_ROOT + '/log/cas.log')
cas_logger.level = Logger::DEBUG

inav_config_file =
  case RAILS_ENV
    when 'development','test'; "config/inav.yml"
    when 'staging', 'produciton';
      if defined?(JRUBY_VERSION)
        require 'jruby'
        catalina_home = Java::JavaLang::System.getProperty('catalina.home')
        "#{catalina_home}/conf/inav/inav.yml"
      else
        "config/inav.yml"
      end
  end

INAV_CONFIG = YAML.load(ERB.new(File.read(inav_config_file)).result)

CASClient::Frameworks::Rails::Filter.configure({
  :logger => cas_logger
}.merge(INAV_CONFIG[:cas]))