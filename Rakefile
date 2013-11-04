require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

# Add default task. When you type just rake command this would run. Travis CI runs this. Making this run spec
desc 'Default: run specs.'
task :default => [:spec]

desc 'Spec: Runs both unit and integration tests'
task :spec => ['spec:unit', 'spec:integration']

namespace :spec do

  desc 'Run unit specs'
  RSpec::Core::RakeTask.new('unit') do |spec|
    spec.pattern = FileList['spec/unit/**/*_spec.rb']
  end

  desc 'Run integration specs'
  RSpec::Core::RakeTask.new('integration') do |spec|
    spec.pattern = 'spec/integration/**/*_spec.rb'
  end

end

# Run the rdoc task to generate rdocs for this gem
require 'rdoc/task'
RDoc::Task.new do |rdoc|
  require 'aggrobot/version'
  version = Aggrobot::VERSION
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = 'aggrobot #{version}'
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

desc 'Spec: Runs both unit and integration tests'
task :coverage => ['coverage:pre', 'coverage:unit', 'coverage:integration']
namespace :coverage do
  task :pre do
    require 'fileutils'
    coverage_folder = File.expand_path('../coverage', __FILE__)
    FileUtils.mkdir_p coverage_folder

    coverage_html = <<-HTML
      <html><body>
        <ul style="list-style:none">
          <li>Aggrobot - Code Coverage</li>
          <li><a href="integration/index.html">Integration Tests</a></li>
          <li><a href="unit/index.html">Unit Tests</a></li>
        </ul>
      </body></html>
    HTML
    File.open(File.join(coverage_folder, 'index.html'), 'w') { |f| f << coverage_html }
  end


  # Ruby 1.9+ using simplecov. Note: Simplecov config defined in spec_helper
  desc "Code coverage unit"
  task :unit do
    ENV['COVERAGE'] = "unit"
    Rake::Task['spec:unit'].execute
  end

  desc "Code coverage integration"
  task :integration do
    ENV['COVERAGE'] = "integration"
    Rake::Task['spec:integration'].execute
  end

end