# frozen_string_literal: true

require 'spec_helper'

describe port(22) do
  it { should be_listening }
end

describe 'Cluster Nodes' do
  describe command('serf members | grep -c "alive"') do 
    it 'There are at least 3 alive nodes' do
      n_nodes = subject.stdout.to_i
      expect(n_nodes).to be > 2
    end
  end
end
