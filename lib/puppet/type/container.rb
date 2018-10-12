require 'puppet/resource_api'

Puppet::ResourceApi.register_type(
  name: 'container',
  docs: <<-EOS,
      This type provides Puppet with the capabilities to manage containers
    EOS
  features: ['canonicalize'],
  attributes:   {
    ensure:      {
      type:    'Enum[present, absent]',
      desc:    'Whether this resource should be present or absent on the target system.',
      default: 'present',
    },
    name:        {
      type:      'String',
      desc:      'The name of the resource you want to manage.',
      behaviour: :namevar,
    },
    image:        {
      type:      'String',
      desc:      'The image of the container',
    },
    image_id:        {
      type:      'String',
      desc:      'The id of the container image',
      behaviour: :read_only,
    },
    id:        {
      type:      'String',
      desc:      'The id of the container',
      behaviour: :read_only,
    },
    status:        {
      type:      'String',
      desc:      'The running status of the container',
      behaviour: :read_only,
    },
    command:        {
      type:      'Array[String]',
      desc:      'The command executed in the container',
    },
  },
)
