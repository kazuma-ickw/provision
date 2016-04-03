package 'mariadb-server'

file '/etc/my.cnf' do
  action :edit
  block do |content|
    lines = content.split("\n")
    mysqld_index = lines.index('[mysqld]')
    lines.insert(mysqld_index, 'user=root')
    mysqld_safe_index = lines.index('[mysqld_safe]')
    lines.insert(mysqld_safe_index - 1, 'character-set-server=utf8')
    lines.insert(mysqld_safe_index - 1, 'skip-character-set-client-handshake')
  end
end

execute 'systemctl enable mariadb' # oops
execute 'systemctl start mariadb' # oops
#package 'mariadb' do
#  action [:enable, :start]
#end

execute 'mysql -e "GRANT ALL PRIVILEGES ON *.* TO \"root\"@\"%\";"'
