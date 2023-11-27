require "rake"
require "rspec/core/rake_task"

task :default => :spec

task :debug => "debug:targets"
namespace :debug do
  desc "a debug task to show what targets are found"
  task :targets do
    targets = []
    Dir.glob("spec/**/*_spec.rb").each do |file|
      host = /(.*)_spec.rb/.match(File.basename(file))[1]
      targets << host
    end
    puts targets
  end
end

task :spec => "spec:all"
namespace :spec do
  host = ENV["TARGET_HOST"] || "10.1.209.20"

  task :all => [:services, :configuration]

  desc "run configuration tests"
  RSpec::Core::RakeTask.new(:configuration) do |t|
    puts "Running configuration tests on #{host} ..."
    t.pattern = "spec/configuration/*_spec.rb"
    t.rspec_opts = "--format documentation"  # O "--format progress"
  end

  desc "run service tests"
  RSpec::Core::RakeTask.new(:services) do |t|
    puts "Running service tests on #{host} ..."
    t.pattern = "spec/services/*_spec.rb"
    t.rspec_opts = "--format documentation"  # O "--format progress"
  end
  desc "rrun monitor test"
  RSpec::Core::RakeTask.new(:services) do |t|
    puts "Running service tests on #{host} ..."
    t.pattern = "spec/modules/monitor/*_spec.rb"
    t.rspec_opts = "--format documentation"  # O "--format progress"
  end
end
