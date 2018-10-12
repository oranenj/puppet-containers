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
      list_containers(_context).map do |c|
          {
              ensure: 'present',
              status: c['status'].downcase,
              # Can a container have multiple names?
              name: c['names'],
              image_id: c['image_id'],
              image: c['image'],
              id: c['id'],
              command: c['command'],
          }
      end
  end

  def create(context, name, should)
    context.notice("Creating '#{name}' with #{should.inspect}")
    podman_cmd('container', 'create', '--name', name, should[:image], *should[:command])
  end

  def update(context, name, should)
    context.notice("Recreating '#{name}' with #{should.inspect}")
    delete(context, name)
    create(context, name, should)
  end

  def delete(context, name)
    context.notice("Deleting '#{name}'")
    # TODO: Figure out if we should use id somehow
    podman_cmd('container', 'rm', name)

  end
end
