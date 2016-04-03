OWNER = 'plant'

user OWNER do
  shell '/sbin/nologin'
end
directory '/var/run/plant' do
  owner OWNER
  group OWNER
end

RUBY_VERSION = '2.0.0-p648'

unless secret_token = ENV['PLANT_SECRET_TOKEN']
  begin
    print "Please enter the your plant's secret_token: "
    secret_token = STDIN.noecho(&:gets).chomp!
    print "\n"
  rescue
    exit 0
  end
end

include_recipe '../docker/main.rb'
include_recipe '../redis-server/main.rb'
include_recipe '../rbenv/main.rb'

%w(git sqlite sqlite-devel).each do |pkg|
  package pkg
end

remote_file '/etc/systemd/system/plant.service' do
  mode '644'
  notifies :run, 'execute[systemctl daemon-reload]', :immediately
end
git '/opt/plant' do
  repository 'https://github.com/kaihar4/plant.git'
end
execute "chown -R #{OWNER}:#{OWNER} /opt/plant"
template '/opt/plant/config/settings.yml' do
  variables(
    secret_token: secret_token,
    redis_host: node['plant']['redis']['host'],
    redis_port: node['plant']['redis']['port']
  )
  mode '644'
end
execute "Install Ruby#{RUBY_VERSION}" do
  command <<-EOS
cd /opt/plant
rbenv install -s #{RUBY_VERSION}
rbenv local #{RUBY_VERSION}
rbenv rehash
  EOS
end
execute 'bundle install' do
  command <<-EOS
cd /opt/plant
bundle install --path vendor/bundle
bundle exec rake db:migrate
  EOS
end
service 'plant' do
  action [:enable, :start]
end
