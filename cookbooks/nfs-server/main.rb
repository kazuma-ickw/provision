package 'nfs-utils'

file '/etc/idmapd.conf' do
  action :edit
  block do |content|
    content.sub!(/^#(Domain\s=.+)/, '\1') unless content =~ /^(Domain\s=).+/
    content.sub!(/^(Domain\s=).+/, '\1 ' + node['domain'])
  end
end

directory '/export' do
  owner 'nfsnobody'
  group 'nfsnobody'
end

service 'rpcbind' do
  action :start
end
service 'nfs-server' do
  action [:enable, :start]
end
