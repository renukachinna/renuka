class ldapauth (
    $host,
    $username,
    $base,
    $password,
    $port = '389',
    $group,
    $namecache = true
){
   $lc = '/etc/ldap.conf'
   $nswc = '/etc/nsswitch.conf'
   $pamconfig = '/etc/pam.d/common-session'
   $commonauth= '/etc/pam.d/common-auth'
   $accessconf= '/etc/security/access.conf'

 
    package { 'ldap-auth-client':
        ensure => installed
    }


    file_line { 'ldap_conf_base':
        ensure => present,
        path   => $lc,
        line => "base $base",
        match => "^base ",
        require => Package['ldap-auth-client'],
    }

    file_line { 'ldap_conf_host':
        ensure  => present,
        path    =>$lc,
        line    => "uri $host",
        match   => "^uri ",
        require => Package['ldap-auth-client'],
    }

    file_line { 'ldap_conf_port':
        ensure  => present,
        path    =>$lc,
        line    => "port $port",
        match   => "^port ",
        require => Package['ldap-auth-client'],
    }

    file_line { 'ldap_conf_password':
        ensure  => present,
        path    =>$lc,
        line    => "bindpw $password",
        match   => "^bindpw ",
        require => Package['ldap-auth-client'],
    }

    file_line { 'ldap_conf_user':
        ensure  => present,
        path    =>$lc,
        line    => "binddn $username",
        match   => "^binddn ",
        require => Package['ldap-auth-client'],
    }

    file_line { 'ldap_conf_rootbind':
        ensure  => present,
        path    =>$lc,
        line    => "rootbinddn $username",
        match   => "^rootbinddn ",
        require => Package['ldap-auth-client'],
    }

     file_line { 'nswitch_passwd':
         ensure  => present,
         path    => $nswc,
         line    => "passwd: files ldap",
         match   => "^passwd: ",
    }
     file_line { 'nswitch_group':
         ensure  => present,
         path    => $nswc,
         line    => "group: files ldap",
         match   => "^group: ",
    }
     file_line { 'nswitch_shadow':
         ensure  => present,
         path    => $nswc,
         line    => "shadow: files ldap",
         match   => "^shadow: ",
    }
    if $namecache == true {
       package { 'nscd': 
         ensure  => installed,
   }

    exec { 'restart-name-cache':
      command => '/etc/init.d/nscd restart',
      require => Package['nscd'],
      subscribe => [
        file_line['nswitch_shadow'],
        file_line['nswitch_group'],
        file_line['nswitch_passwd'],
        file_line['ldap_conf_base'],
        file_line['ldap_conf_host'],
        file_line['ldap_conf_port'],
        file_line['ldap_conf_password'],
        file_line['ldap_conf_user'],
        file_line['ldap_conf_rootbind']],
       }
    } 
    file { '/usr/share/pam-configs':
         ensure  => directory,

    } 

    file { '/usr/share/pam-configs/my_mkhomedir':
         ensure  => file,
         source  => 'puppet:///modules/ldapauth/homedir',
     }

     file_line { 'pam_mkhomedir':
         ensure => present,
         path  => $pamconfig,
         line  => "session required  pam_mkhomedir.so umask=0022 skel=/etc/skel",
         match=> "^session required  pam_mkhomedir.so umask=0022 skel=/etc/skel",
    }

     file_line { 'common-auth':
         ensure => present,
         path  => $commonauth,
         line  => "auth   required  pam_access.so",
         match => "^auth   required  pam_access.so",
    }

     file { '/etc/security/access.conf':
         ensure => present,
         content=> template ('/etc/puppet/modules/ldapauth/templates/ldap.group.erb')
        
    }

         
}



