RBENV_VERSION = 'v1.0.0'

%w(git gcc gcc-c++ openssl-devel readline-devel zlib-devel bzip2).each do |pkg|
  package pkg
end

git '/opt/rbenv' do
  repository 'https://github.com/sstephenson/rbenv.git'
  revision RBENV_VERSION
  notifies :create, 'file[/etc/profile.d/rbenv.sh]', :immediately
  notifies :run, 'execute[source /etc/profile.d/rbenv.sh]', :immediately
end
git '/opt/rbenv/plugins/ruby-build' do
  repository 'https://github.com/sstephenson/ruby-build.git'
end
git '/opt/rbenv/plugins/rbenv-default-gems' do
  repository 'https://github.com/sstephenson/rbenv-default-gems.git'
  notifies :create, 'file[/opt/rbenv/default-gems]', :immediately
end
git '/opt/rbenv/plugins/rbenv-gem-rehash' do
  repository 'https://github.com/sstephenson/rbenv-gem-rehash.git'
end
