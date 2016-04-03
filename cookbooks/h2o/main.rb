OPENSSL_PKG_NAME = 'OpenSSL_1_0_2g'
CMAKE_VERSION = 'v3.4.2'
H2O_VERSION = 'v2.0.0-beta4'

OWNER = 'h2o'

user OWNER do
  shell '/sbin/nologin'
end
directory '/etc/h2o'
directory '/var/run/h2o'
directory '/var/log/h2o'

%w(git gcc gcc-c++ bison openssl-devel ruby-devel).each do |pkg|
  package pkg
end

git '/usr/local/src/cmake' do
  repository 'https://github.com/Kitware/CMake.git'
  revision CMAKE_VERSION
  notifies :run, 'execute[Compile cmake]', :immediately
end

git '/usr/local/src/openssl' do
  repository 'https://github.com/openssl/openssl.git'
  revision OPENSSL_PKG_NAME
  notifies :run, 'execute[Compile openssl]', :immediately
end

remote_file '/etc/systemd/system/h2o.service' do
  mode '644'
  notifies :run, 'execute[systemctl daemon-reload]', :immediately
end
execute 'Initialize h2o' do
  command <<-EOS
cd /usr/local/src/h2o
git reset --hard HEAD
rm -f CMakeCache.txt
  EOS

  only_if 'test -d /usr/local/src/h2o'
end
git '/usr/local/src/h2o' do
  repository 'https://github.com/h2o/h2o.git'
  revision H2O_VERSION
  recursive
  notifies :run, 'execute[Compile h2o]', :immediately
end

file '/etc/h2o/h2o.conf' do
  content <<-EOS
user: h2o
pid-file: /var/run/h2o/h2o.pid

listen:
  port: 80

hosts:
  "default":
    paths:
      /:
        redirect:
          status: 301
          url: https://kaihar4.com/
  EOS

  mode '644'
	not_if 'test -e /etc/h2o/h2o.conf'
end

service 'h2o' do
  action [:enable, :start]
end
remote_file '/etc/logrotate.d/h2o' do
  mode '644'
end
