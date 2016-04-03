file '/etc/dnsmasq.conf' do
  action :edit
  block do |content|
    content.sub!(/^#(domain-needed)$/, '\1') unless content =~ /^(domain-needed)$/
    content.sub!(/^#(bogus-priv)$/, '\1') unless content =~ /^(bogus-priv)$/
    content.sub!(/^#(expand-hosts)$/, '\1') unless content =~ /^(expand-hosts)$/
    content.sub!(/^#(local=.+)$/, '\1') unless content =~ /^(local=).+$/
    content.sub!(/^#(domain=[^,]+)$/, '\1') unless content =~ /^(domain=)[^,]+$/
    content.sub!(/^#(port=\d+)$/, '\1') unless content =~ /^(port=)\d+$/

    content.sub!(/^(local=).+$/, '\1' + "/#{node['localdomain']}/")
    content.sub!(/^(domain=)[^,]+$/, '\1' + node['localdomain'])
    content.sub!(/^(port=)\d+$/, '\1' + '53')
  end
end
service 'dnsmasq' do
  action [:enable, :start]
end
