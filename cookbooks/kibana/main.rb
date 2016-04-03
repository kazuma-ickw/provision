ES_PKG_NAME = 'elasticsearch-2.2.0'
KIBANA_PKG_NAME  = 'kibana-4.3.1-linux-x64'

OWNER = 'kibana'

user OWNER do
  shell '/sbin/nologin'
end

%w(java-1.8.0-openjdk tar which).each do |pkg|
  package pkg
end

remote_file '/etc/systemd/system/kibana.service' do
  mode '644'
  notifies :run, 'execute[systemctl daemon-reload]', :immediately
end
remote_file '/etc/systemd/system/elasticsearch.service' do
  mode '644'
  notifies :run, 'execute[systemctl daemon-reload]', :immediately
end
execute 'Install elasticsearch' do
  command <<-EOS
curl -sL https://download.elasticsearch.org/elasticsearch/elasticsearch/#{ES_PKG_NAME}.tar.gz | tar -zxf- -C /opt
mv /opt/#{ES_PKG_NAME} /opt/elasticsearch
chown -R #{OWNER} /opt/elasticsearch
  EOS

  not_if 'test -d "/opt/elasticsearch"'
end
file '/opt/elasticsearch/config/elasticsearch.yml' do
  action :edit
  block do |content|
    content.sub!(/#(discovery\.zen\.ping\.multicast\.enabled:) false/, '\1 false')
    append_config = <<-EOS
http.cors.enabled: true
http.cors.allow-origin: '/.*/'
threadpool.search.queue_size: -1
    EOS
    unless content.include?(append_config)
      content << append_config
    end
  end
end

execute 'Install kibana' do
  command <<-EOS
curl -sL https://download.elasticsearch.org/kibana/kibana/#{KIBANA_PKG_NAME}.tar.gz | tar -zxf- -C /opt
mv /opt/#{KIBANA_PKG_NAME} /opt/kibana
chown -R #{OWNER} /opt/kibana
  EOS

  not_if 'test -d "/opt/kibana"'
end
service 'elasticsearch' do
  action [:enable, :start]
end
service 'kibana' do
  action [:enable, :start]
end
