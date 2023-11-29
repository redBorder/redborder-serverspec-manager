# frozen_string_literal: true

require 'spec_helper'

describe port(22) do
  it { should be_listening }
end
