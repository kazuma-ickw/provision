execute 'yum groupinstall -y "KDE Plasma Workspaces"' do
  notifies :create, 'file[/etc/profile.d/x.sh]', :immediately
end

link '/etc/systemd/system/default.target' do
  to '/usr/lib/systemd/system/graphical.target'
  force true
end
