require 'rspec/core/rake_task'
require 'rubocop/rake_task'

RSpec::Core::RakeTask.new(:spec)

RuboCop::RakeTask.new(:rubocop) do |task|
  task.options = ['--display-cop-names']
  task.requires << 'rubocop-rspec'
end

task default: %i[spec rubocop]
