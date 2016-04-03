execute "timedatectl set-timezone #{node['timezone']}" do
  not_if "timedatectl status | grep #{node['timezone']}"
  notifies :restart, 'service[rsyslog]', :immediately
end

execute 'yum update -y'

package 'iptables-services'
service 'iptables' do
  action [:enable, :start]
end
service 'firewalld' do
  action [:disable, :stop]
end

hostname = node['hostname']
template '/usr/local/bin/iptables.sh' do
  variables(
    tcp_open_ports: node[hostname]['tcp_open_ports'],
    udp_open_ports: node[hostname]['udp_open_ports'],
    allow: node['trust_cidrs'],
    deny: node['vicious_cidrs']
  )
  mode '755'
  notifies :run, 'execute[/usr/local/bin/iptables.sh > /etc/sysconfig/iptables]', :immediately
  notifies :reload, 'service[iptables]', :immediately
end

template '/etc/cron.d/metrics' do
  variables(
    mailto: node['mailto']
  )
  mode '644'
end
remote_file '/etc/logrotate.d/metrics'

directory '/mnt/tmpfs'
file '/etc/fstab' do
  action :edit
  block do |content|
    append_config = "tmpfs /mnt/tmpfs tmpfs defaults,size=512m 0 0\n"
    unless content.include?(append_config)
      content << append_config
    end
  end
  notifies :run, 'execute[mount -a]', :immediately
end

file '/etc/postfix/main.cf' do
  action :edit
  block do |content|
    content.sub!(/^#(mydomain\s+=.+)$/, '\1') unless content =~ /^(mydomain\s+=).+$/
    content.sub!(/^(mydomain\s+=).+$/, '\1 ' + node['domain'])
  end
  notifies :reload, 'service[postfix]', :immediately
end
