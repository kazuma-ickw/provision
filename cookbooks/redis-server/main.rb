%w(epel-release redis).each do |pkg|
  package pkg
end

file '/etc/redis.conf' do
  action :edit
  block do |content|
    content.sub!(/(bind 127\.0\.0\.1)/, '#\1')
  end
end

service 'redis' do
  action [:enable, :start]
end
