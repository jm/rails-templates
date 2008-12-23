# suspenders.rb
# from Nathan Esquenazi
# based on Suspenders by Thoughtbot

#====================
# PLUGINS
#====================

plugin 'hoptoad_notifier', :git => "git://github.com/thoughtbot/hoptoad_notifier.git"
plugin 'limerick_rake', :git => "git://github.com/thoughtbot/limerick_rake.git"
plugin 'mile_marker', :git => "git://github.com/thoughtbot/mile_marker.git"
plugin 'squirrel', :git => "git://github.com/thoughtbot/squirrel.git"

#====================
# GEMS
#====================

gem 'RedCloth', :lib => 'redcloth', :version => '~> 3.0.4'
gem 'mislav-will_paginate'
gem 'mocha'
gem 'thoughtbot-factory_girl'
gem 'thoughtbot-shoulda'
gem 'thoughtbot-quietbacktrace'

freeze!
# rake("gems:install", :sudo => true)
# rake("gems:unpack")

#====================
# APP
#====================

file 'app/controllers/application_controller.rb', 
%q{class ApplicationController < ActionController::Base

  helper :all

  protect_from_forgery

  include HoptoadNotifier::Catcher

end
}

file 'app/helpers/application_helper.rb', 
%q{module ApplicationHelper
  def body_class
    "#{controller.controller_name} #{controller.controller_name}-#{controller.action_name}"
  end
end
}

file 'app/views/layouts/_flashes.html.erb', 
%q{<div id="flash">
  <% flash.each do |key, value| -%>
    <div id="flash_<%= key %>"><%=h value %></div>
  <% end -%>
</div>
}

file 'app/views/layouts/application.html.erb', 
%q{<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" 
  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
  <head>
    <meta http-equiv="Content-type" content="text/html; charset=utf-8" />
    <title><%= PROJECT_NAME.humanize %></title>
    <%= stylesheet_link_tag 'screen', :media => 'all', :cache => true %>
    <%= javascript_include_tag :defaults, :cache => true %>
  </head>
  <body class="<%= body_class %>">
    <%= render :partial => 'layouts/flashes' -%>
    <%= yield %>
  </body>
</html>
}

#====================
# INITIALIZERS
#====================

initializer 'action_mailer_configs.rb', 
%q{ActionMailer::Base.smtp_settings = {
    :address => "smtp.thoughtbot.com",
    :port    => 25,
    :domain  => "thoughtbot.com"
}
}

initializer 'errors.rb', 
%q{# Example:
#   begin
#     some http call
#   rescue *HTTP_ERRORS => error
#     notify_hoptoad error
#   end

HTTP_ERRORS = [Timeout::Error,
               Errno::EINVAL,
               Errno::ECONNRESET,
               EOFError,
               Net::HTTPBadResponse,
               Net::HTTPHeaderSyntaxError,
               Net::ProtocolError]

SMTP_SERVER_ERRORS = [TimeoutError,
                      IOError,
                      Net::SMTPUnknownError,
                      Net::SMTPServerBusy,
                      Net::SMTPAuthenticationError]

SMTP_CLIENT_ERRORS = [Net::SMTPFatalError,
                      Net::SMTPSyntaxError]

SMTP_ERRORS = SMTP_SERVER_ERRORS + SMTP_CLIENT_ERRORS
}


initializer 'hoptoad.rb', 
%q{HoptoadNotifier.configure do |config|
  config.api_key = 'HOPTOAD-KEY'
end
}

initializer 'mocks.rb', 
%q{# Rails 2 doesn't like mocks

# This callback will run before every request to a mock in development mode, 
# or before the first server request in production. 

Rails.configuration.to_prepare do
  Dir[File.join(RAILS_ROOT, 'test', 'mocks', RAILS_ENV, '*.rb')].each do |f|
    load f
  end
end
}

initializer 'requires.rb', 
%q{require 'redcloth'

Dir[File.join(RAILS_ROOT, 'lib', 'extensions', '*.rb')].each do |f|
  require f
end

Dir[File.join(RAILS_ROOT, 'lib', '*.rb')].each do |f|
  require f
end
}

initializer 'time_formats.rb', 
%q{# Example time formats
{ :short_date => "%x", :long_date => "%a, %b %d, %Y" }.each do |k, v|
  ActiveSupport::CoreExtensions::Time::Conversions::DATE_FORMATS.update(k => v)
end
}

# ====================
# CONFIG
# ====================

capify!

file 'config/environment.rb', 
%q{# Be sure to restart your server when you modify this file

# Change this to the name of your rails project, like carbonrally.  
# Just use the same name as the svn repo.
PROJECT_NAME = "CHANGEME"

throw "The project's name in environment.rb is blank" if PROJECT_NAME.empty?
throw "Project name (#{PROJECT_NAME}) must_be_like_this" unless PROJECT_NAME =~ /^[a-z_]*$/

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.0' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.

  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.
  # See Rails::Configuration for more options.

  # Skip frameworks you're not going to use. To use Rails without a database
  # you must remove the Active Record framework.
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Specify gems that this application depends on.
  config.gem 'RedCloth',
             :lib => 'redcloth', 
             :version => '~> 3.0.4'
  config.gem 'mislav-will_paginate', 
             :lib => 'will_paginate', 
             :source => 'http://gems.github.com', 
             :version => '~> 2.3.5'
  config.gem 'mocha', 
             :version => '>= 0.9.2'
  config.gem 'quietbacktrace', 
             :version => '>= 0.1.1'
  config.gem 'thoughtbot-factory_girl', 
             :lib => 'factory_girl', 
             :source => 'http://gems.github.com', 
             :version => '>= 1.1.3'
  config.gem 'thoughtbot-shoulda', 
             :lib => 'shoulda', 
             :source => 'http://gems.github.com', 
             :version => '>= 2.0.5'
  
  # Only load the plugins named here, in the order given. By default, all plugins 
  # in vendor/plugins are loaded in alphabetical order.
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]
  
  # Add the vendor/gems/*/lib directories to the LOAD_PATH
  config.load_paths += Dir.glob(File.join(RAILS_ROOT, 'vendor', 'gems', '*', 'lib'))

  # Force all environments to use the same logger level
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Make Time.zone default to the specified zone, and make Active Record store time values
  # in the database in UTC, and return them converted to the specified local zone.
  # Run "rake -D time" for a list of tasks for finding time zone names. Uncomment to use default local time.
  config.time_zone = 'UTC'

  # Your secret key for verifying cookie session data integrity.
  # If you change this key, all old sessions will become invalid!
  # Make sure the secret is at least 30 characters and all random, 
  # no regular words or you'll be exposed to dictionary attacks.
  SESSION_KEY = "CHANGESESSION" 
  config.action_controller.session = {
    :session_key => "_#{PROJECT_NAME}_session",
    :secret      => SESSION_KEY
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
}

file 'Capfile', 
%q{load 'deploy' if respond_to?(:namespace) # cap2 differentiator
Dir['vendor/plugins/*/recipes/*.rb'].each { |plugin| load(plugin) }
load 'config/deploy'
}

file 'config/database.yml', 
%q{<% PASSWORD_FILE = File.join(RAILS_ROOT, '..', '..', 'shared', 'config', 'dbpassword') %>

development:
  adapter: mysql
  database: <%= PROJECT_NAME %>_development
  username: root
  password: 
  host: localhost
  encoding: utf8
  
test:
  adapter: mysql
  database: <%= PROJECT_NAME %>_test
  username: root
  password: 
  host: localhost
  encoding: utf8
  
staging:
  adapter: mysql
  database: <%= PROJECT_NAME %>_staging
  username: <%= PROJECT_NAME %>
  password: <%= File.read(PASSWORD_FILE).chomp if File.readable? PASSWORD_FILE %>
  host: localhost
  encoding: utf8
  socket: /var/lib/mysql/mysql.sock
  
production:
  adapter: mysql
  database: <%= PROJECT_NAME %>_production
  username: <%= PROJECT_NAME %>
  password: <%= File.read(PASSWORD_FILE).chomp if File.readable? PASSWORD_FILE %>
  host: localhost
  encoding: utf8
  socket: /var/lib/mysql/mysql.sock
}

file 'config/deploy.rb', 
%q{set :stages, %w(staging production)
set :default_stage, 'staging'
require 'capistrano/ext/multistage'

before "deploy:setup", "db:password"

namespace :deploy do
  desc "Default deploy - updated to run migrations"
  task :default do
    set :migrate_target, :latest
    update_code
    migrate
    symlink
    restart
  end
  desc "Start the mongrels"
  task :start do
    send(run_method, "cd #{deploy_to}/#{current_dir} && #{mongrel_rails} cluster::start --config #{mongrel_cluster_config}")
  end
  desc "Stop the mongrels"
  task :stop do
    send(run_method, "cd #{deploy_to}/#{current_dir} && #{mongrel_rails} cluster::stop --config #{mongrel_cluster_config}")
  end
  desc "Restart the mongrels"
  task :restart do
    send(run_method, "cd #{deploy_to}/#{current_dir} && #{mongrel_rails} cluster::restart --config #{mongrel_cluster_config}")
  end
  desc "Run this after every successful deployment" 
  task :after_default do
    cleanup
  end
end

namespace :db do
  desc "Create database password in shared path" 
  task :password do
    set :db_password, Proc.new { Capistrano::CLI.password_prompt("Remote database password: ") }
    run "mkdir -p #{shared_path}/config" 
    put db_password, "#{shared_path}/config/dbpassword" 
  end
end
}

file 'config/deploy/staging.rb', 
%q{# For migrations
set :rails_env, 'staging'

# Who are we?
set :application, 'CHANGEME'
set :repository, "git@github.com:thoughtbot/#{application}.git"
set :scm, "git"
set :deploy_via, :remote_cache
set :branch, "staging"

# Where to deploy to?
role :web, "staging.example.com"
role :app, "staging.example.com"
role :db,  "staging.example.com", :primary => true

# Deploy details
set :user, "#{application}"
set :deploy_to, "/home/#{user}/apps/#{application}"
set :use_sudo, false
set :checkout, 'export'

# We need to know how to use mongrel
set :mongrel_rails, '/usr/local/bin/mongrel_rails'
set :mongrel_cluster_config, "#{deploy_to}/#{current_dir}/config/mongrel_cluster_staging.yml"
}

file 'config/deploy/production.rb', 
%q{# For migrations
set :rails_env, 'production'

# Who are we?
set :application, 'CHANGEME'
set :repository, "git@github.com:thoughtbot/#{application}.git"
set :scm, "git"
set :deploy_via, :remote_cache
set :branch, "production"

# Where to deploy to?
role :web, "production.example.com"
role :app, "production.example.com"
role :db,  "production.example.com", :primary => true

# Deploy details
set :user, "#{application}"
set :deploy_to, "/home/#{user}/apps/#{application}"
set :use_sudo, false
set :checkout, 'export'

# We need to know how to use mongrel
set :mongrel_rails, '/usr/local/bin/mongrel_rails'
set :mongrel_cluster_config, "#{deploy_to}/#{current_dir}/config/mongrel_cluster_production.yml"
}

file 'config/environments/development.rb', 
%q{# Settings specified here will take precedence over those in config/environment.rb

# In the development environment your application's code is reloaded on
# every request.  This slows down response time but is perfect for development
# since you don't have to restart the webserver when you make code changes.
config.cache_classes = false

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_controller.perform_caching             = false
config.action_view.debug_rjs                         = true

# Don't care if the mailer can't send
config.action_mailer.raise_delivery_errors = false

HOST = 'localhost'
}

file 'config/environments/production.rb', 
%q{# Settings specified here will take precedence over those in config/environment.rb

# The production environment is meant for finished, "live" apps.
# Code is not reloaded between requests
config.cache_classes = true

# Use a different logger for distributed setups
# config.logger = SyslogLogger.new

# Full error reports are disabled and caching is turned on
config.action_controller.consider_all_requests_local = false
config.action_controller.perform_caching             = true

# Enable serving of images, stylesheets, and javascripts from an asset server
# config.action_controller.asset_host                  = "http://assets.example.com"

# Disable delivery errors, bad email addresses will be ignored
config.action_mailer.raise_delivery_errors = false
}

file 'config/environments/staging.rb', 
%q{# Settings specified here will take precedence over those in config/environment.rb

# We'd like to stay as close to prod as possible
# Code is not reloaded between requests
config.cache_classes = true

# Full error reports are disabled and caching is turned on
config.action_controller.consider_all_requests_local = false
config.action_controller.perform_caching             = true

# Disable delivery errors if you bad email addresses should just be ignored
config.action_mailer.raise_delivery_errors = false
}

file 'config/environments/test.rb', 
%q{# Settings specified here will take precedence over those in config/environment.rb

# The test environment is used exclusively to run your application's
# test suite.  You never need to work with it otherwise.  Remember that
# your test database is "scratch space" for the test suite and is wiped
# and recreated between test runs.  Don't rely on the data there!
config.cache_classes = true

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_controller.perform_caching             = false

# Disable request forgery protection in test environment
config.action_controller.allow_forgery_protection    = false

# Tell ActionMailer not to deliver emails to the real world.
# The :test delivery method accumulates sent emails in the
# ActionMailer::Base.deliveries array.
config.action_mailer.delivery_method = :test

HOST = 'localhost'

require 'quietbacktrace'
require 'factory_girl'
require 'mocha'
begin require 'redgreen'; rescue LoadError; end
}

file 'config/mongrel_cluster_production.yml', 
%q{--- 
# cwd: /home/CHANGEME/apps/CHANGEME/current
# port: "3030"
environment: production
address: 127.0.0.1
pid_file: log/mongrel.pid
servers: 3
}

file 'config/mongrel_cluster_staging.yml', 
%q{--- 
# cwd: /home/CHANGEME/apps/CHANGEME/current
# port: "3030"
environment: staging
address: 127.0.0.1
pid_file: log/mongrel.pid
servers: 2
}

inside('db') do
  run "mkdir bootstrap"
end

# ====================
# TEST
# ====================

inside ('test') do
  run "mkdir factories"
end

file 'test/shoulda_macros/forms.rb', 
%q{class Test::Unit::TestCase
  def self.should_have_form(opts)
    model = self.name.gsub(/ControllerTest$/, '').singularize.downcase
    model = model[model.rindex('::')+2..model.size] if model.include?('::')
    http_method, hidden_http_method = form_http_method opts[:method]
    should "have a #{model} form" do
      assert_select "form[action=?][method=#{http_method}]", eval(opts[:action]) do
        if hidden_http_method
          assert_select "input[type=hidden][name=_method][value=#{hidden_http_method}]"
        end
        opts[:fields].each do |attribute, type|
          attribute = attribute.is_a?(Symbol) ? "#{model}[#{attribute.to_s}]" : attribute
          assert_select "input[type=#{type.to_s}][name=?]", attribute
        end
        assert_select "input[type=submit]"
      end
    end
  end

  def self.form_http_method(http_method)
    http_method = http_method.nil? ? 'post' : http_method.to_s
    if http_method == "post" || http_method == "get"
      return http_method, nil
    else
      return "post", http_method
    end
  end  
end
}

file 'test/shoulda_macros/pagination.rb', 
%q{class Test::Unit::TestCase
  # Example:
  #  context "a GET to index logged in as admin" do
  #    setup do
  #      login_as_admin 
  #      get :index
  #    end
  #    should_paginate_collection :users
  #    should_display_pagination
  #  end
  def self.should_paginate_collection(collection_name)
    should "paginate #{collection_name}" do
      assert collection = assigns(collection_name), 
        "Controller isn't assigning to @#{collection_name.to_s}."
      assert_kind_of WillPaginate::Collection, collection, 
        "@#{collection_name.to_s} isn't a WillPaginate collection."
    end
  end
  
  def self.should_display_pagination
    should "display pagination" do
      assert_select "div.pagination", { :minimum => 1 }, 
        "View isn't displaying pagination. Add <%= will_paginate @collection %>."
    end
  end
  
  # Example:
  #  context "a GET to index not logged in as admin" do
  #    setup { get :index }
  #    should_not_paginate_collection :users
  #    should_not_display_pagination
  #  end
  def self.should_not_paginate_collection(collection_name)
    should "not paginate #{collection_name}" do
      assert collection = assigns(collection_name), 
        "Controller isn't assigning to @#{collection_name.to_s}."
      assert_not_equal WillPaginate::Collection, collection.class, 
        "@#{collection_name.to_s} is a WillPaginate collection."
    end
  end
  
  def self.should_not_display_pagination
    should "not display pagination" do
      assert_select "div.pagination", { :count => 0 }, 
        "View is displaying pagination. Check your logic."
    end
  end
end
}

file 'test/test_helper.rb', 
%q{ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'
require 'action_view/test_case'

class Test::Unit::TestCase

  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures  = false

  self.backtrace_silencers << :rails_vendor
  self.backtrace_filters   << :rails_root

end

class ActionView::TestCase
  # Enable UrlWriter when testing helpers
  include ActionController::UrlWriter
  # Default host for helper tests
  default_url_options[:host] = HOST
end
}

# ====================
# FINALIZE
# ====================

run "rm public/index.html"
run "touch public/stylesheets/screen.css"
run 'find . \( -type d -empty \) -and \( -not -regex ./\.git.* \) -exec touch {}/.gitignore \;'
git :init
git :add => "."
git :commit => "-a -m 'Initial project commit'"