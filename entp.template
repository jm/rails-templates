# entp.rb
# from Jeremy McAnally

plugin 'rspec', :git => 'git://github.com/dchelimsky/rspec.git'
plugin 'rspec-rails', :git => 'git://github.com/dchelimsky/rspec-rails.git'
plugin 'restful-authentication', :git => 'git://github.com/technoweenie/restful-authentication.git'
plugin 'open_id_authentication', :git => 'git://github.com/rails/open_id_authentication.git'
plugin 'exception_notifier', :git => 'git://github.com/rails/exception_notification.git'

gem 'mislav-will-paginate'
gem 'ruby-openid'
gem 'rubyist-aasm'

rakefile "bootstrap.rake", <<CODE
  namespace :app do
    task :bootstrap do
    end
    
    task :seed do
    end
  end
CODE

generate("authenticated", "user session")
generate("rspec")
