%w(nodejs npm).each do |pkg|
  package pkg
end

execute 'npm install -g grunt-cli' do
  not_if 'which grunt'
end

remote_file '/etc/systemd/system/reveal.js.service' do
  mode '644'
  notifies :run, 'execute[systemctl daemon-reload]', :immediately
end
git '/opt/reveal.js' do
  repository 'https://github.com/hakimel/reveal.js.git'
end
execute 'npm' do
  command <<-EOS
cd /opt/reveal.js
npm install
  EOS
end
service 'reveal.js' do
  action [:enable, :start]
end
