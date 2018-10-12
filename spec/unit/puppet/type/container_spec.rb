require 'spec_helper'
require 'puppet/type/container'

RSpec.describe 'the container type' do
  it 'loads' do
    expect(Puppet::Type.type(:container)).not_to be_nil
  end
end
