require 'bundler'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new('spec')

Bundler::GemHelper.install_tasks

desc 'Run tests'
task :default => :spec
