class guest_additions::vmware {
  exec { 'extract-tools':
    command => "/bin/tar -zxf $guest_additions::mount_point/*.tar.gz -C /tmp",
    require => Exec['mount-cd'],
    creates => '/tmp/vmware-tools-distrib',
    before  => Exec['unmount'],
  }

  exec { 'install-vmware-tools':
    command => '/tmp/vmware-tools-distrib/vmware-install.pl -d',
    require => Exec['extract-tools'],
    creates => '/etc/vmware-tools',
  }

  exec { 'remove-tmp-vmware':
    require => Exec['install-vmware-tools'],
    command => '/bin/rm -Rf /tmp/vmware-tools-distrib',
  }
}
