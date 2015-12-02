class { 'ldapauth':
   host     => 'ldap://10.0.2.2:389/',
   username => 'cn=Directory Manager',
   base => 'dc=ex,dc=com',
   password => 'admin123',
   namecache=> true,
   group    => 'text',
}

