package 'dovecot'

file '/etc/dovecot/conf.d/10-mail.conf' do
  action :edit
  block do |content|
    content.sub!(/^#(mail_location\s+=.+)/, '\1') unless content =~ /^(mail_location\s+=).+/
    content.sub!(/^(mail_location\s+=).+/, '\1 maildir:~/Maildir')
  end
end

file '/etc/dovecot/conf.d/10-auth.conf' do
  action :edit
  block do |content|
    content.sub!(/^#(disable_plaintext_auth\s+=.+)/, '\1') unless content =~ /^(disable_plaintext_auth\s+=).+/
    content.sub!(/^(disable_plaintext_auth\s+=).+/, '\1 no')
  end
end

file '/etc/dovecot/conf.d/10-ssl.conf' do
  action :edit
  block do |content|
    content.sub!(/^(ssl\s+=).+/, '\1 yes')
    content.sub!(/^(ssl_cert\s+=).+/, '\1 </etc/pki/tls/certs/mail.crt')
    content.sub!(/^(ssl_key\s+=).+/, '\1 </etc/pki/tls/certs/mail.key')
  end
end

service 'dovecot' do
  action [:enable, :start]
end
