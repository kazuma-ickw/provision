hostname = node['hostname']

directory '/etc/h2o'
remote_file '/etc/h2o/h2o.conf' do
  not_if 'test -e /etc/h2o/h2o.conf'
  notifies :reload, 'service[h2o]', :immediately
end

include_recipe '../h2o/main.rb'

git '/opt/letsencrypt' do
  repository 'https://github.com/lukas2511/letsencrypt.sh.git'
end

directory '/opt/letsencrypt/.acme-challenges'
file '/opt/letsencrypt/config.sh' do
  mode '644'
end
template '/opt/letsencrypt/domains.txt' do
  variables(
    domains: node[hostname]['certificate_domains']
  )
  mode '644'
  notifies :run, 'execute[/opt/letsencrypt/letsencrypt.sh -c]', :immediately
end
template '/etc/cron.d/letsencrypt' do
  variables(
    mailto: node['mailto'],
    services: node[hostname]['tls_services']
  )
  mode '644'
end
