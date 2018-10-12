require 'spec_helper'
require 'puppet/type/container_pod'

RSpec.describe 'the container_pod type' do
  it 'loads' do
    expect(Puppet::Type.type(:container_pod)).not_to be_nil
  end
end
