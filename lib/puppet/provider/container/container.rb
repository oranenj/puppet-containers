require 'puppet/resource_api/simple_provider'

# Implementation for the container type using the Resource API.
class Puppet::Provider::Container::Container < Puppet::ResourceApi::SimpleProvider
  def podman_cmd(_context, *args)
      args.unshift('/usr/bin/podman')
      return Puppet::Util::Execution.execute(args, failonfail: true)
  end

  def list_containers(context)
      result = podman_cmd(context, 'container', 'ls', '--all', '--format', 'json')
      JSON.parse(result) || []
  end

  def canonicalize(context, resources)
      resources.each do |r|
          image = r[:image]

          next unless image
          unless image.index('/')
              # no namespace, assuming default:
              image = "docker.io/library/#{image}"
          end
          unless image.index(':')
              # no version, assume latest
              image = "#{image}:latest"
          end
          r[:image] = image
      end
  end

  def get(_context)
      containers = list_containers(_context)
      return [] if containers == []
      ids = containers.map { |c| c['id'] } 
      # Get detailed info and put it into a hash keyed by ID for easier access
      # This is somewhat of a hack. We store the user's "extra_options" array as container metadata
      # so that it's easy to detect if it has been changed or not
      c_info = JSON.parse(podman_cmd(_context, 'container', 'inspect', *ids))
      c_info = Hash[c_info.map{|x| [x["ID"], x]}]

      containers.map do |c|
          extra_options = c_info[c['id']]['Config']['Annotations'].fetch('org.voxpupuli.puppet-extra-options', "[]")
          {
              ensure: 'present',
              status: c['status'].downcase,
              # Can a container have multiple names?
              name: c['names'],
              image_id: c['image_id'],
              image: c['image'],
              id: c['id'],
              command: c['command'],
              extra_options: JSON.parse(extra_options),
          }
      end
  end

  def create(context, name, should)
    context.notice("Creating '#{name}' with #{should.inspect}")
    args = ['--name', name]
    if should[:extra_options] != []
        json = JSON.generate should[:extra_options]
        args.concat ["--annotation", "org.voxpupuli.puppet-extra-options=#{json}"]
    end
    args << should[:image]
    args.concat should[:command]
    podman_cmd('container', 'create', *args)
  end

  def update(context, name, should)
    context.notice("Recreating '#{name}' with #{should.inspect}")
    delete(context, name, should[:force])
    create(context, name, should)
  end

  def delete(context, name, force = false)
    context.notice("Deleting '#{name}'")
    cmd = ['container', 'rm']
    if force
        cmd << '-f'
    end
    cmd << name

    # TODO: Figure out if we should use id somehow
    podman_cmd(context, cmd)

  end
end
