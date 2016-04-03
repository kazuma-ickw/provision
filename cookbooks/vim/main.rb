VIM_VERSION = 'v7.4.1694'

%w(gcc ncurses-devel lua lua-devel python-devel ruby-devel libXt-devel).each do |pkg|
  package pkg
end

git '/usr/local/src/vim' do
  repository 'https://github.com/vim/vim.git'
  revision VIM_VERSION
  notifies :run, 'execute[Compile vim]', :immediately
  notifies :create, 'file[/etc/profile.d/vim.sh]', :immediately
end
