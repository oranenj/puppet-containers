# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include containers::install
class containers::install {
    String $package_name = $containers::package_name,
    String $version      = $containers::package_version,
} {
  package {$package_name:
    ensure => $version
  }
}
