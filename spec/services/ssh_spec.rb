# frozen_string_literal: true
require 'spec_helper'

describe port(22) do
  it { should be_listening }
end

describe 'Service is enabled and running' do
  describe service('sshd') do
    it { should be_enabled }
    it { should be_running }
  end
end


NODE_LIST = command('red node list 2>/dev/null').stdout.chomp.split("\n")
describe 'Executing commands into nodes one by one' do
  it 'There is at least one node in the list' do
    expect(NODE_LIST).not_to be_empty
  end

  NODE_LIST.each do |node|
    it "Executing basic echo on Node: #{node}" do
      result = command("red node execute #{node} 'echo SERVERSPEC'")
      expect(result.exit_status).to eq(0)
      expect(result.stdout).to include(node.to_s)
      expect(result.stdout).to include('SERVERSPEC')
    end
  end
end

