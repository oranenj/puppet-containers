require 'puppet/resource_api/simple_provider'
require 'puppet/util/execution'
require 'json'

# Implementation for the podman_pod type using the Resource API.
class Puppet::Provider::PodmanPod::PodmanPod < Puppet::ResourceApi::SimpleProvider
  def podman_cmd(_context, *args)
      args.unshift('/usr/bin/podman')
      return Puppet::Util::Execution.execute(args, failonfail: true)
  end

  def list_pods(context)
      result = podman_cmd(context, 'pod', 'ls', '--format', 'json')
      JSON.parse(result) || []
  end

  def set(context, changes)
      changes.each do |name, change|
          is = change.key?(:is) ? change[:is] : (get(context, [name]) || []).find { |r| r[:name] == name }
          context.type.check_schema(is) unless change.key?(:is)
          should = change[:should]
          is = { name: name, ensure: 'absent' } if is.nil?
          should = { name: name, ensure: 'absent' } if should.nil?
          if is[:ensure].to_s == 'absent' && should[:ensure].to_s != 'absent'
              context.creating(name) do
                create(context, name, should)
                set_state(context, name, is, should)
              end
          elsif is[:ensure].to_s == 'present' && should[:ensure].to_s == 'absent'
              context.deleting(name) do
                  delete(context, name, should)
              end
          elsif is[:ensure].to_s == 'present' && should[:ensure].to_s != 'absent'
              context.updating(name) do
                  set_state(context, name, is, should)
              end
          end
      end
  end

  def get(context)
      pods = list_pods(context)
      pods.map do |p|
          { 
              ensure: :present,
              state: p['status'].downcase,
              name: p['name'],
              id: p['id'],
              share: p['namespaces'],
              cgroup: p['cgroup'],
          }
    end
  end

  def create(context, name, should)
    context.notice("Creating '#{name}' with #{should.inspect}")
    args = ['pod', 'create' '--name', name]
    if should[:share]
        args.push('--share', should[:share].join(','))
    end
    podman_cmd(context, *args)
  end

  def set_state(context, name, is, should)
      return unless should[:state]
      context.notice("Setting state to #{should[:ensure]} for '#{name}'")
      cmd = nil
      case should[:state].to_s
      when 'running'
          cmd = 'start'
          if is[:ensure].to_s == 'paused'
              cmd = 'unpause'
          end
      when 'stopped'
          cmd = 'stop'
      when 'paused'
          cmd = 'pause'
      end
      podman_cmd(context, 'pod', cmd, 'name')
  end

  def delete(context, name, should)
    context.notice("Deleting '#{name}'")
    podman_cmd(context, 'pod', 'rm', name)
  end
end
