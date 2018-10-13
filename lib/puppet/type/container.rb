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
    pod:        {
      type:      'Optional[String]',
      desc:      'The pod to run the container in.',
    },
    volumes:        {
      type:      'Optional[Array[String]]',
      desc:      'The volume definitions for the container',
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
    force:        {
      type:      'Boolean',
      desc:      'Use force when removing or updating containers',
      default:   false,
      behaviour: :parameter,
    },
    extra_options:        {
      type:      'Array[String]',
      desc:      'An array of extra options passed to podman when creating the container',
      default: []
    },
  },
  autorequires: {
    class:      'containers',
    container_pod: '$pod',
  }
)
