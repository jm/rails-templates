# inspired by http://www.rowtheboat.com/archives/32

# have specs
plugin 'rspec',
  :git => 'git://github.com/dchelimsky/rspec.git'
plugin 'rspec-rails',
  :git => 'git://github.com/dchelimsky/rspec-rails.git'

generate("rspec")

# get all datamapper related gems (assume sqlite3 to be database)
gem "addressable", :lib => "addressable/uri"
gem "data_objects"
gem "do_sqlite3"
gem "dm-core"
gem "rails_datamapper"

rake "gems:install"

# install datamapper rake tasks
generate("dm-install")

# fix config/environment.rb to work with datamapper instead of active_record
run "sed -i config/environment.rb -e 's/#.*config.plugins.*/config.plugins = [ :rails_datamapper, :all ]/'"
run "sed -i config/environment.rb -e 's/#.*config.frameworks.*/config.frameworks -= [ :active_record ]/'"

# set up git
git :init
git :add => '.'
git :commit => "-a -m 'Initial commit'"
