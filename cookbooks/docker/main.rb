file '/etc/yum.repos.d/docker.repo' do
  content <<-EOF
[dockerrepo]
name=Docker Repository
baseurl=https://yum.dockerproject.org/repo/main/centos/7
enabled=1
gpgcheck=1
gpgkey=https://yum.dockerproject.org/gpg
  EOF
end
package 'docker-engine'

file '/usr/lib/systemd/system/docker.service' do
  action :edit
  block do |content|
    append_config = '--dns 8.8.8.8'
    unless content.include?(append_config)
      content.sub!(/^(ExecStart=.+)$/, '\1 ' + append_config)
    end
  end
  notifies :run, 'execute[systemctl daemon-reload]', :immediately
end

service 'docker' do
  action [:enable, :start]
end
