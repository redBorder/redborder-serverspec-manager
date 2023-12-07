# frozen_string_literal: truezz<<SxczxZ
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

NODE_LIST_DELEGATE = "red node list 2>/dev/null"
describe 'Getting node names' do
  describe command NODE_LIST_DELEGATE do
    its('exit_status') { should eq 0 }
    its('stdout') { should_not be_empty }
  end
end

nodes = command(NODE_LIST_DELEGATE).stdout.chomp.split("\n")
describe 'Executing commands into nodes one by one' do
  it 'At least one node is present' do
    expect(nodes).not_to be_empty
  end
end

describe 'Executing commands into nodes one by one' do
  nodes.each do |node|
    it "Executing on Node: #{node}" do
      result = command("red node execute #{node} 'echo SERVERSPEC'")
      expect(result.exit_status).to eq(0)
      expect(result.stdout).to include("#{node}")
      expect(result.stdout).to include("SERVERSPEC")
    end
  end
end
