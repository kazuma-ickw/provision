%w(epel-release nginx).each do |pkg|
  package pkg
end

directory '/var/cache/nginx'
directory '/var/log/nginx'
directory '/var/run/nginx'

file '/usr/lib/systemd/system/nginx.service' do
  action :edit
  block do |content|
    content.sub!('/run/nginx.pid', '/var/run/nginx/nginx.pid')
  end
  notifies :run, 'execute[systemctl daemon-reload]', :immediately
end

remote_file '/etc/nginx/nginx.conf' do
  mode '644'
end

service 'nginx' do
  action [:enable, :start]
end
