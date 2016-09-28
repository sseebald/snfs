class snfs {

  file { 'C:\temp': 
    ensure => directory,
  }

  file { 'C:\temp\7z920-x64.msi':
    ensure => present,
    source => 'puppet:///modules/snfs/7z920-x64.msi',
    require => File['C:\temp'],
  }

  file { 'C:\temp\test.ps1': 
    ensure => present,
    source => 'puppet:///modules/snfs/test.ps1',
    require => File['C:\temp'],
  }

  class { 'archive':
    seven_zip_name     => '7-Zip 9.20 (x64 edition)',
    seven_zip_source   => 'C:/temp/7z920-x64.msi',
    seven_zip_provider => 'windows',
  }

  file { 'C:\temp\snfs_client_Windows_x86_64_unattended_puppet.zip': 
    ensure => present,
    source => 'puppet:///modules/snfs/snfs_client_Windows_x86_64_unattended_puppet.zip',
    require => File['C:\temp'],
  }

  archive { 'C:\temp\snfs_client_Windows_x86_64_unattended_puppet.zip':
    path          => 'C:\temp\snfs_client_Windows_x86_64_unattended_puppet.zip',
    extract       => true,
    extract_path  => 'C:\temp',
    creates       => 'C:\temp\snfs_client_Windows_x86_64_unattended_puppet',
    require       => File['C:\temp\snfs_client_Windows_x86_64_unattended_puppet.zip'],
  }

  acl { 'C:\temp\snfs_client_Windows_x86_64_unattended_puppet':
    inherit_parent_permissions => 'false',
    permissions                => [ 
                                    {'identity' => 'Everyone', 'rights' => ['full']}, 
                                    {'identity' => 'NT AUTHORITY\SYSTEM', 'rights' => ['full']}, 
                                    {'identity' => 'BUILTIN\Administrators', 'rights' => ['full']},
				  ],
  }  

  exec { 'install stornext':
    provider => 'powershell',
    command => 'C:\temp\test.ps1',
    path => 'C:\temp',
    onlyif => 'if (Get-WmiObject Win32_product -Filter "Name=\'StorNext File System\'") { exit 1 }',
    require => [ File['C:\temp\test.ps1'],Acl['C:\temp\snfs_client_Windows_x86_64_unattended_puppet'] ],
  }

  reboot { 'if pending':
    when => pending,
  }

}
