require 'puppet/resource_api'

Puppet::ResourceApi.register_type(
  name: 'container_pod',
  docs: <<-EOS,
      This type provides Puppet with the capabilities to manage container pods
    EOS
  features: [],
  attributes:   {
    ensure:      {
      type:    'Enum[present, absent]',
      desc:    'Controls the existence of the pod.',
      default: 'present',
    },
    state:        {
      type:      "Optional[Enum['running', 'paused', 'stopped']]",
      desc:      'The running state of the pod',
    },
    name:        {
      type:      'String',
      desc:      'The name of the resource you want to manage.',
      behaviour: :namevar,
    },
    id:        {
      type:      'String',
      desc:      'The ID of the pod.',
      behaviour: :read_only,
    },
    id:        {
      type:      'String',
      desc:      'The CGroup containing the pod',
      behaviour: :read_only,
    },
    share: {
      type:      "Array[Enum['cgroup','ipc','net','uts']]",
      desc:      'The namespaces that containers in the pod will share.',
      behaviour: :init_only,
    },
  },
)
