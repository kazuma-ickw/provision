%w(cyrus-sasl cyrus-sasl-md5 cyrus-sasl-plain).each do |pkg|
  package pkg
end

file '/etc/postfix/authinfo' do
  content "#{node['mail']['postfix']['relayhost']} #{node['mail']['postfix']['authinfo']}"
  mode '640'
  notifies :run, 'execute[postmap /etc/postfix/authinfo]', :immediately
end
execute 'mkdir -p /etc/skel/Maildir/{new,cur,tmp}'
execute 'chmod -R 700 /etc/skel/Maildir'
file '/etc/postfix/main.cf' do
  action :edit
  block do |content|
    content.sub!(/^#(myhostname\s+=.+)$/, '\1') unless content =~ /^(myhostname\s+=).+$/
    content.sub!(/^#(mydomain\s+=.+)$/, '\1') unless content =~ /^(mydomain\s+=).+$/
    content.sub!(/^#(relayhost\s+=.+)$/, '\1') unless content =~ /^(relayhost\s+=).+$/
    content.sub!(/^#(myorigin\s+=.+)$/, '\1') unless content =~ /^(myorigin\s+=).+$/
    content.sub!(/^#(mynetworks\s+=.+)$/, '\1') unless content =~ /^(mynetworks\s+=).+$/
    content.sub!(/^#(smtpd_banner\s+=.+)$/, '\1') unless content =~ /^(smtpd_banner\s+=).+$/
    content.sub!(/^#(home_mailbox\s+=.+)$/, '\1') unless content =~ /^(home_mailbox\s+=).+$/

    content.sub!(/^(myhostname\s+=).+$/, '\1 ' + node['mail']['host'])
    content.sub!(/^(mydomain\s+=).+$/, '\1 ' + node['domain'])
    content.sub!(/^(relayhost\s+=).+$/, '\1 ' + node['mail']['postfix']['relayhost'])
    content.sub!(/^(myorigin\s+=).+$/, '\1 $mydomain')
    content.sub!(/^(mynetworks\s+=).+$/, '\1 ' + node['trust_cidrs'].join(','))
    content.sub!(/^(smtpd_banner\s+=).+$/, '\1 $myhostname ESMTP unknown')
    content.sub!(/^(home_mailbox\s+=).+$/, '\1 Maildir/')

    content.sub!(/^(mydestination\s+=).+$/, '\1 $myhostname, localhost.$mydomain, localhost, $mydomain')

    append_config = <<-EOS
smtp_sasl_auth_enable = yes
smtp_sasl_password_maps = hash:/etc/postfix/authinfo
smtp_sasl_security_options = noanonymous
smtp_sasl_mechanism_filter = LOGIN, CRAM-MD5, PLAIN

smtpd_tls_security_level = may
smtpd_tls_cert_file = /etc/pki/tls/certs/mail.crt
smtpd_tls_key_file = /etc/pki/tls/certs/mail.key
smtpd_tls_session_cache_database = btree:/var/lib/postfix/smtpd_scache
smtpd_sasl_local_domain = $myhostname
smtpd_sasl_security_options = noanonymous
smtpd_recipient_restrictions = permit_mynetworks, permit_sasl_authenticated, reject_unauth_destination
message_size_limit = 10485760
    EOS
    unless content.include?(append_config)
      content << append_config
    end
  end
  notifies :reload, 'service[postfix]', :immediately
end
file '/etc/postfix/master.cf' do
  action :edit
  block do |content|
    content.sub!(/^#(smtps\s+inet\s+n\s+-\s+n\s+-\s+-\s+smtpd)$/, '\1') unless content =~ /^(smtps\s+inet\s+n\s+-\s+n\s+-\s+-\s+smtpd)$/
    unless content =~ /^(\s+-o\s+smtpd_tls_wrappermode=yes)$\n^(\s+-o\s+smtpd_sasl_auth_enable=yes)$/
      content.sub!(/^#(\s+-o\s+smtpd_tls_wrappermode=yes)$\n^#(\s+-o\s+smtpd_sasl_auth_enable=yes)$/, '\1' + "\n" + '\2')
    end
  end
  notifies :reload, 'service[postfix]', :immediately
end
file '/etc/postfix/main.cf' do
  action :edit
  block do |content|
    content.sub!(/^(inet_interfaces\s+=).+$/, '\1 all')
  end
  notifies :restart, 'service[postfix]', :immediately
end

service 'saslauthd' do
  action [:enable, :start]
end
