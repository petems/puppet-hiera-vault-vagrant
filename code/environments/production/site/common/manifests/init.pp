# common class that gets applied to all nodes
# See: "code/environments/production/hieradata/common.yaml"
# It:
#  - configures /etc/hosts entries
#  - makes sure puppet is installed and running
#  - makes sure mcollective + client is installed and running
#
class common {

  # needed for rubygem-stomp
  yumrepo { 'puppetlabs-deps':
    ensure  => 'present',
    baseurl => 'http://yum.puppetlabs.com/el/7/dependencies/$basearch',
    descr   => 'Puppet Labs Dependencies El 7 - $basearch',
    enabled => '1',
  }

  host { 'puppet':
    ip => '10.13.37.2',
  }

  host { 'node1':
    ip => '10.13.37.3',
  }

  package { 'puppet-agent':
    ensure => installed,
  }

  service { 'puppet':
    ensure  => running,
    enable  => true,
    require => Package['puppet-agent'],
  }

  class { '::mcollective':
    middleware_hosts          => [ 'puppet' ],
    psk                       => 'puppet',
    middleware_user           => 'puppet',
    middleware_password       => 'puppet',
    middleware_admin_user     => 'puppet',
    middleware_admin_password => 'puppet',
    client                    => true,
    require                   => Yumrepo['puppetlabs-deps'],
  }

}
