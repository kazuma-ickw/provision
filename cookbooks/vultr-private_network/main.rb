hostname = node['hostname']

file '/etc/sysconfig/network-scripts/ifcfg-eth1' do
  content <<-EOS
DEVICE=eth1
ONBOOT=yes
NM_CONTROLLED=no
BOOTPROTO=static
IPADDR=#{node[hostname]['ip']}
NETMASK=255.255.0.0
IPV6INIT=no
MTU=1450
  EOS

  notifies :restart, 'service[network]', :immediately
end
