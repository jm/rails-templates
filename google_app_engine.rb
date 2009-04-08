#Google App Engine template

run 'jruby -S gem install warbler'

inside(ENV['RAILS_ROOT']) do
  run 'jruby -S warble pluginize'
  run 'jruby -S warble config'
end

freeze! 'RELEASE=2.3.2'
run 'rm -rf vendor/rails/activerecord'
%w(actionmailer actionpack activeresource activesupport railties).each do |gem|
  run %Q{rm -rf vendor/rails/#{gem}/test}
end

inside('lib') do
  
  # A LITTLE TRICK TO GET ALL THE MANDATORY JARS FASTER
  run 'git clone git://github.com/olabini/yarbl.git'
  run 'cp yarbl/lib/*.jar . && rm -rf yarbl'
  
  run 'git clone git://github.com/olabini/bumble.git'
  run 'git clone git://github.com/olabini/beeu.git'
  
  # GET THE DEVELOPMENT VERSION OF JRUBY
  # run 'git clone git://github.com/jruby/jruby.git'
  # run 'ant jruby-complete'

  # run 'mkdir tmp_unpack
  # cd tmp_unpack
  # jar xf ../jruby-complete.jar
  # cd ..
  # mkdir jruby-core
  # mv tmp_unpack/org jruby-core/
  # mv tmp_unpack/com jruby-core/
  # mv tmp_unpack/jline jruby-core/
  # mv tmp_unpack/jay jruby-core/
  # mv tmp_unpack/jruby jruby-core/
  # cd jruby-core
  # jar cf ../jruby-core.jar .
  # cd ../tmp_unpack
  # jar cf ../ruby-stdlib.jar .
  # cd ..
  # rm -rf jruby-core
  # rm -rf tmp_unpack
  # rm -rf jruby-complete.jar
  # rm -rf jruby'
  
  # GET THE DEVELOPMENT VERSION OF JRUBY-RACK
  #run 'git clone git://github.com/nicksieger/jruby-rack.git'
  #run %q{cd jruby-rack && mvn package && mv target/jruby-rack-*.jar ../ && cd .. && rm -rf jruby-rack}
  
end

file 'appengine-web.xml',
%Q{<?xml version="1.0" encoding="utf-8"?>
<appengine-web-app xmlns="http://appengine.google.com/ns/1.0">
  <application>#{root.split('/').last}</application>
  <version>2</version>
  <static-files />
  <resource-files />
  <sessions-enabled>true</sessions-enabled>
  <system-properties>
    <property name="jruby.management.enabled" value="false" />
    <property name="os.arch" value="" />
    <property name="jruby.compile.mode" value="JIT"/> <!-- JIT|FORCE|OFF -->
    <property name="jruby.compile.fastest" value="true"/>
    <property name="jruby.compile.frameless" value="true"/>
    <property name="jruby.compile.positionless" value="true"/>
    <property name="jruby.compile.threadless" value="false"/>
    <property name="jruby.compile.fastops" value="false"/>
    <property name="jruby.compile.fastcase" value="false"/>
    <property name="jruby.compile.chainsize" value="500"/>
    <property name="jruby.compile.lazyHandles" value="false"/>
    <property name="jruby.compile.peephole" value="true"/>
 </system-properties>
</appengine-web-app>
}

file 'datastore-indexes.xml',
%q{<?xml version="1.0" encoding="utf-8"?>
  <datastore-indexes autoGenerate="true">
</datastore-indexes>
}

file 'config/environment.rb',
%q{# Be sure to restart your server when you modify this file

  # Uncomment below to force Rails into production mode when
  # you don't control web/app server and can't set it the proper way
  # ENV['RAILS_ENV'] ||= 'production'

  # Specifies gem version of Rails to use when vendor/rails is not present
  RAILS_GEM_VERSION = '2.3.2' unless defined? RAILS_GEM_VERSION

  # Bootstrap the Rails environment, frameworks, and default configuration
  require File.join(File.dirname(__FILE__), 'boot')

  require 'big_table_servlet_store'

  Rails::Initializer.run do |config|
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    # See Rails::Configuration for more options.

    # Skip frameworks you're not going to use. To use Rails without a database
    # you must remove the Active Record framework.
    config.frameworks -= [ :active_record ]

    # Specify gems that this application depends on. 
    # They can then be installed with "rake gems:install" on new installations.
    # You have to specify the :lib option for libraries, where the Gem name (sqlite3-ruby) differs from the file itself (sqlite3)
    # config.gem "bj"
    # config.gem "hpricot", :version => '0.6', :source => "http://code.whytheluckystiff.net"
    # config.gem "sqlite3-ruby", :lib => "sqlite3"
    # config.gem "aws-s3", :lib => "aws/s3"

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

    # The internationalization framework can be changed to have another default locale (standard is :en) or more load paths.
    # All files from config/locales/*.rb,yml are added automatically.
    # config.i18n.load_path << Dir[File.join(RAILS_ROOT, 'my', 'locales', '*.{rb,yml}')]
    # config.i18n.default_locale = :de

    # Your secret key for verifying cookie session data integrity.
    # If you change this key, all old sessions will become invalid!
    # Make sure the secret is at least 30 characters and all random, 
    # no regular words or you'll be exposed to dictionary attacks.
    config.action_controller.session = {
      :session_key => '_yarbl_session',
      :secret      => 'a8071c8e98c4862f8a801525f39fd5167680258a4415a9a68afab2ab98c445c1dd4abc66e3bb2089365434d54234aef7feb62b78a08c2f749e0ed6aeea369af7'
    }

    # Use the database for sessions instead of the cookie-based default,
    # which shouldn't be used to store highly confidential information
    # (create the session table with "rake db:sessions:create")

    config.action_controller.session_store = :big_table_servlet_store

    # Use SQL instead of Active Record's schema dumper when creating the test database.
    # This is necessary if your schema can't be completely dumped by the schema dumper,
    # like if you have constraints or database-specific column types
    # config.active_record.schema_format = :sql

    # Activate observers that should always be running
    # Please note that observers generated using script/generate observer need to have an _observer suffix
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer
  end

  require 'bumble'
}

file 'config/warble.rb',
%q{# Warbler web application assembly configuration file
Warbler::Config.new do |config|
  # Temporary directory where the application is staged
  # config.staging_dir = "tmp/war"

  # Application directories to be included in the webapp.
  config.dirs = %w(app config lib log vendor tmp)

  # Additional files/directories to include, above those in config.dirs
  config.includes = FileList["appengine-web.xml", "datastore-indexes.xml"]

  # Additional files/directories to exclude
  # config.excludes = FileList["lib/tasks/*"]

  # Additional Java .jar files to include.  Note that if .jar files are placed
  # in lib (and not otherwise excluded) then they need not be mentioned here.
  # JRuby and JRuby-Rack are pre-loaded in this list.  Be sure to include your
  # own versions if you directly set the value
  # config.java_libs += FileList["lib/java/*.jar"]

  # Loose Java classes and miscellaneous files to be placed in WEB-INF/classes.
  # config.java_classes = FileList["target/classes/**.*"]

  # One or more pathmaps defining how the java classes should be copied into
  # WEB-INF/classes. The example pathmap below accompanies the java_classes
  # configuration above. See http://rake.rubyforge.org/classes/String.html#M000017
  # for details of how to specify a pathmap.
  # config.pathmaps.java_classes << "%{target/classes/,}p"

  # Gems to be included. You need to tell Warbler which gems your application needs
  # so that they can be packaged in the war file.
  # The Rails gems are included by default unless the vendor/rails directory is present.
  # config.gems += ["activerecord-jdbcmysql-adapter", "jruby-openssl"]
  # config.gems << "tzinfo"

  # Uncomment this if you don't want to package rails gem.
  # config.gems -= ["rails"]

  # The most recent versions of gems are used.
  # You can specify versions of gems by using a hash assignment:
  # config.gems["rails"] = "2.0.2"

  # You can also use regexps or Gem::Dependency objects for flexibility or
  # fine-grained control.
  # config.gems << /^merb-/
  # config.gems << Gem::Dependency.new("merb-core", "= 0.9.3")

  # Include gem dependencies not mentioned specifically
  config.gem_dependencies = true

  # Files to be included in the root of the webapp.  Note that files in public
  # will have the leading 'public/' part of the path stripped during staging.
  # config.public_html = FileList["public/**/*", "doc/**/*"]

  # Pathmaps for controlling how public HTML files are copied into the .war
  # config.pathmaps.public_html = ["%{public/,}p"]

  # Name of the war file (without the .war) -- defaults to the basename
  # of RAILS_ROOT
  # config.war_name = "mywar"

  # Value of RAILS_ENV for the webapp -- default as shown below
  # config.webxml.rails.env = ENV['RAILS_ENV'] || 'production'

  # Application booter to use, one of :rack, :rails, or :merb. (Default :rails)
  # config.webxml.booter = :rails

  # When using the :rack booter, "Rackup" script to use.
  # The script is evaluated in a Rack::Builder to load the application.
  # Examples:
  # config.webxml.rackup = %{require './lib/demo'; run Rack::Adapter::Camping.new(Demo)}
  # config.webxml.rackup = require 'cgi' && CGI::escapeHTML(File.read("config.ru"))

  # Control the pool of Rails runtimes. Leaving unspecified means
  # the pool will grow as needed to service requests. It is recommended
  # that you fix these values when running a production server!
  config.webxml.jruby.min.runtimes = 1
  config.webxml.jruby.max.runtimes = 2
  config.webxml.jruby.init.serial = true
#  config.webxml.jruby.runtime.initializer.threads = 1
  # config.webxml.jruby.max.runtimes = 4

  # JNDI data source name
  # config.webxml.jndi = 'jdbc/rails'

  config.java_libs = []
end}

file 'config/environments/production.rb',
%q{# Settings specified here will take precedence over those in config/environment.rb

# The production environment is meant for finished, "live" apps.
# Code is not reloaded between requests
config.cache_classes = true

# Enable threaded mode
# config.threadsafe!

class ServletContextLogger
  def debug(progname = nil, &block)
    log(:DEBUG, progname, &block)
  end

  def error(progname = nil, &block)
    log(:ERROR, progname, &block)
  end

  def fatal(progname = nil, &block)
    log(:FATAL, progname, &block)
  end

  def info(progname = nil, &block)
    log(:INFO, progname, &block)
  end

  def warn(progname = nil, &block)
    log(:WARN, progname, &block)
  end
  
  def log(severity, progname, &block)
    message = progname || block.call
    $servlet_context.log("#{severity}: #{message}")
  end
  
  def method_missing(name, *args, &block)
  end
end

# Use a different logger for distributed setups
config.logger = ServletContextLogger.new

# Full error reports are disabled and caching is turned on
config.action_controller.consider_all_requests_local = false
config.action_controller.perform_caching             = true

# Use a different cache store in production
# config.cache_store = :mem_cache_store

# Enable serving of images, stylesheets, and javascripts from an asset server
# config.action_controller.asset_host                  = "http://assets.example.com"

# Disable delivery errors, bad email addresses will be ignored
# config.action_mailer.raise_delivery_errors = false}