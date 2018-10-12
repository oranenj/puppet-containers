
# containers

#### Table of Contents

1. [Description](#description)
2. [Setup - The basics of getting started with containers](#setup)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Limitations - OS compatibility, etc.](#limitations)
5. [Development - Guide for contributing to the module](#development)

## Description

This module installs `podman` and provides types and manifests to use it for container management on a host.

## Setup

```
# just install podman
include 'containers'

```

## Usage

```puppet
# Creates (but does not run) a container
container {'my_container':
  image => 'alpine',
  command => ['echo', 'hello world'],
}
```

```puppet
# Manage the container defined above as a systemd service
container::service {'my_container':}
```



## Limitations

  - Only systemd-based operating systems are fully supported at the moment


## Development

Still working on initial release.
