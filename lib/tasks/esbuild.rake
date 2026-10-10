namespace :assets do
  task :build_esbuild do
    puts "Building JavaScript with esbuild..."

    success = system("yarn", "build")

    abort "esbuild compilation failed" unless success
  end
end

Rake::Task["assets:precompile"].enhance(["assets:build_esbuild"])