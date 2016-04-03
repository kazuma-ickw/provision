execute 'curl -L http://toolbelt.treasuredata.com/sh/install-redhat-td-agent2.sh | sh' do
  not_if 'test -e "/usr/sbin/td-agent"'
end
directory '/etc/td-agent/conf.d'

service 'td-agent' do
  action [:enable, :start]
end
