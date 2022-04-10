namespace :spec do
  desc "Generate rspec coverage report"
  task :generate_coverage_report do
    ENV["COVERAGE_ANALYSIS"] = 'true'
    Rake::Task["spec"].execute
  end
end
