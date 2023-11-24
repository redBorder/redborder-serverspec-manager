require 'spec_helper'
set :os, :family => 'redhat', :release => '9', :arch => 'x86_64'

describe interface('ens160') do
  it { should exist }
end