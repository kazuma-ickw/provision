RUBY_VERSION = '2.3.0'

include_recipe '../rbenv/main.rb'

%w(git epel-release nodejs npm).each do |pkg|
  package pkg
end

execute 'npm install -g gulp'

git '/opt/kaihar4.com' do
  repository 'https://github.com/kaihar4/kaihar4.com.git'
end
execute "Install Ruby#{RUBY_VERSION}" do
  command <<-EOS
cd /opt/kaihar4.com
rbenv install -s #{RUBY_VERSION}
rbenv local #{RUBY_VERSION}
rbenv rehash
  EOS
end
execute 'bundle install' do
  command <<-EOS
cd /opt/kaihar4.com
npm install
bundle install --path vendor/bundle
bundle exec middleman build
  EOS
end
