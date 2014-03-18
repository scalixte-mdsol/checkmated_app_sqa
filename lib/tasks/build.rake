desc "Generate config files using dice_bag's rake tasks"
task :build do
  Rake::Task['config:deploy'].invoke
end
