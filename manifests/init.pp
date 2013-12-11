class guest_additions (
  $cd_image     = $guest_additions::params::cd_image,
  $cd_device    = $guest_additions::params::cd_device,
  $mount_point  = $guest_additions::params::mount_point,
  $platform     = $guest_additions::params::platform,
  $remove_iso   = $guest_additions::params::remove_iso,
) inherits guest_additions::params {


  if $cd_image {
    file { "$guest_additions::mount_point":
      ensure => directory,
    }
    exec { 'mount-cd':
      command => "/bin/mount -o loop $guest_additions::cd_image $guest_additions::mount_point",
      require => File["$guest_additions::mount_point"],
    } 
    exec { 'unmount':
      command => "/bin/umount $guest_additions::mount_point",
    }

    if $guest_additions::remove_iso {
      exec { 'remove_iso':
        command => "/bin/rm $guest_additions::cd_image",
        require => Exec['unmount'],
      } 
    }
  } elsif $cd_device {
    exec { 'mount-cd':
      command => "/bin/mount $guest_additions::cd_device $guest_additions::mount_point",
      require => File["$guest_additions::mount_point"],
    } 
    exec { 'unmount':
      command => "/bin/umount $guest_additions::mount_point",
    }
  } else {
    notify { 'no-cd':
      message => 'No CD image or device specified - skipping guest additions',
    }
  }


  if $platform == 'vmware' {
    class { 'guest_additions::vmware':
      require => Exec['mount-cd'],
    }
  }
  elsif $guest_additions::platform == 'virtualbox' {
    class { 'guest_additions::virtualbox':
      require => Exec['mount-cd'],
    }
  } else {
    notify { 'no-additions':
      message => "No automatically installable guest additions for $guest_additions::platform",
    }
  }
}
