require 'fileutils'
require 'colorize'

class DependencyInjection
  #APPMAP_GEM      = "gem 'appmap', github: 'applandinc/appmap-ruby', branch: 'master'"
  APPMAP_GEM      = "gem 'appmap'"
  APPMAP_RAILTIE  = "require 'appmap/railtie'"
  APPMAP_RSPEC    = "require 'appmap/rspec'"
  APPMAP_MINITEST = "require 'appmap/minitest'"
  APPMAP_CUCUMBER = "require 'appmap/cucumber'"
  APPMAP_COMMENT  = "# --- APPMAP ---"
  APPMAP_HOOKS = %q(
  if AppMap::Cucumber.enabled?
    Around('not @appmap-disable') do |scenario, block|
      appmap = AppMap.record do
        block.call
      end

      AppMap::Cucumber.write_scenario(scenario, appmap)
    end
  end
  )

  def initialize(directory)
    raise ArgumentError.new("directory does not exist") if not File.directory?(directory)
    @working_directory = directory
  end

  def generate_all_dependencies
    puts "\nGenerating appmap dependencies..."
    puts "This script will make a backup of any file it modifies and save the "\
         "original with the postfix ~".yellow
    start = Time.now
    generate_appmap_yml
    generate_gemfile
    generate_test_dependencies
    generate_railties_dependencies
    stop = Time.now
    puts "Appmap dependencies generated in %f seconds\n".green % (stop - start)
  end

  def generate_appmap_yml
    puts "creating appmap.yml..."
    if File.file?("appmap.yml")
      puts "appmap.yml already exists, skipping...".red
      return
    end
    name = "name: %s" % File.basename(@working_directory)
    paths = get_paths().map { |x| "  - path: %s" % x }

    if paths.empty?
      puts "warning: no paths found, make sure to configure appmap.yml manually".yellow
      File.open('appmap.yml', 'w') do |f|
        f.puts(name)
        f.puts('packages:')
      end
      return
    end

    File.open('appmap.yml', 'w') do |f|
      f.puts(name)
      f.puts('packages:')
      paths.each { |path| f.puts(path) }
    end
    puts "appmap.yml generated successfully".green
  end

  def get_paths
    paths = []
    if File.directory?('app')
      Dir['app/*'].each do |d|
        if Dir[d + '/**/*.rb'].any?
          paths.append(d)
        end
      end
    end
    if File.directory?('lib')
      paths.append('lib')
    end
    return paths
  end

  def generate_gemfile
    puts "adding appmap gem to Gemfile..."
    if not File.file?("Gemfile")
      puts "Gemfile does not exist, skipping...".red
      return
    end
    FileUtils.cp('Gemfile', 'Gemfile~')
    contents = File.open('Gemfile').readlines.map(&:chomp)
    if contents[0] =~ /frozen_string_literal/
      contents.insert(1, "\n" + APPMAP_COMMENT)
      contents.insert(2, APPMAP_GEM)
    else
      contents.insert(0, APPMAP_COMMENT)
      contents.insert(1, APPMAP_GEM + "\n\n")
    end

    File.open('Gemfile','w') do |f|
      contents.each { |line| f.puts(line) }
    end
    puts "Gemfile successfully updated".green
  end

  def generate_test_dependencies()
    if File.directory?('spec')
      generate_rspec_dependencies()
    end
    if File.directory?('test')
      generate_minitest_dependencies()
    end
    if File.directory?('features/support')
      generate_cucumber_dependencies()
    end
  end

  def generate_rspec_dependencies
    puts "adding appmap rspec dependency..."
    if not File.file?("spec/spec_helper.rb")
      puts "spec/spec_helper.rb not found, if this app uses rspec unit testing, "\
           "please follow https://github.com/applandinc/appmap-ruby#rspec".red
      return
    end
    FileUtils.cp('spec/spec_helper.rb', 'spec/spec_helper.rb~')
    contents = File.open('spec/spec_helper.rb').readlines.map(&:chomp)
    if contents[0] =~ /frozen_string_literal/
      contents.insert(1, "\n" + APPMAP_COMMENT)
      contents.insert(2, APPMAP_RSPEC)
    else
      contents.insert(0, "\n" + APPMAP_COMMENT)
      contents.insert(1, APPMAP_RSPEC)
    end
    File.open('spec/spec_helper.rb', 'w') do |f|
      contents.each { |line| f.puts(line) }
    end
    puts "appmap/rspec spec_helper.rb dependency added successfully".green
  end

  def generate_minitest_dependencies
    puts "adding appmap minitest dependency..."
    if not File.file?("test/test_helper.rb")
      puts "test/test_helper.rb not found, if this app uses minitest unit testing, "\
           "please follow https://github.com/applandinc/appmap-ruby#minitest".red
      return
    end
    FileUtils.cp('test/test_helper.rb', 'test/test_helper.rb~')
    contents = File.open('test/test_helper.rb').readlines.map(&:chomp)
    if contents[0] =~ /frozen_string_literal/
      contents.insert(1, "\n" + APPMAP_COMMENT)
      contents.insert(2, APPMAP_MINITEST)
    else
      contents.insert(0, APPMAP_COMMENT)
      contents.insert(1, APPMAP_MINITEST + "\n\n")
    end
    File.open('test/test_helper.rb', 'w') do |f|
      contents.each { |line| f.puts(line) }
    end
    puts "appmap/minitest test_helper.rb dependency added successfully".green
  end

  def generate_cucumber_dependencies
    puts "adding appmap cucumber dependencies..."
    if not File.file?("features/support/env.rb")
      puts "feature/support/env.rb not found, if this app uses cucumber unit testing, "\
           "please follow https://github.com/applandinc/appmap-ruby#cucumber".red
      return
    end

    # config env.rb
    FileUtils.cp('features/support/env.rb', 'features/support/env.rb~')
    contents = File.open('features/support/env.rb').readlines.map(&:chomp)
    if contents[0] =~ /frozen_string_literal/
      contents.insert(1, "\n" + APPMAP_COMMENT)
      contents.insert(2, APPMAP_CUCUMBER)
    else
      contents.insert(0, APPMAP_COMMENT)
      contents.insert(1, APPMAP_CUCUMBER + "\n\n")
    end
    File.open('features/support/env.rb', 'w') do |f|
      contents.each { |line| f.puts(line) }
    end
    puts "appmap/cucumber env.rb dependency added successfully".green

    # config hooks.rb
    if not File.file?('features/support/hooks.rb')
      puts "hooks.rb does not exist, creating hooks.rb..."
      File.open('features/support/hooks.rb', 'w') do |f|
        f.puts APPMAP_COMMENT
        f.puts APPMAP_HOOKS
      end
    else
      FileUtils.cp('features/support/hooks.rb', 'features/support/hooks.rb~')
      contents = File.open('features/support/hooks.rb').readlines.map(&:chomp)
      if contents[0] =~ /frozen_string_literal/
        contents.insert(1, "\n" + APPMAP_COMMENT)
        contents.insert(2, APPMAP_CUCUMBER)
      else
        contents.insert(0, APPMAP_COMMENT)
        contents.insert(1, APPMAP_CUCUMBER + "\n\n")
      end
      File.open('features/support/hooks.rb', 'w') do |f|
        contents.each { |line| f.puts(line) }
      end
    end
    puts "appmap/cucumber hooks.rb dependency added successfully".green
  end

  def generate_railties_dependencies
    if not File.file?("config/application.rb")
      puts "this script only supports automatic railties dependency if "\
           "config/application.rb exists. If this application requires railties "\
           "and uses a different method of loading, please add `require 'appmap/railties'` "\
           "to the relevant file after `require 'rails/all'` or `require '.../railties'`".yellow
      return
    else
      puts "adding appmap/railties dependency..."
      FileUtils.cp('config/application.rb', 'config/application.rb~')

      contents = File.open('config/application.rb').readlines.map(&:chomp)
      contents.each_with_index do |line, index|
        if line =~ /rails\/all/
          contents.insert(index+1, "\n" + APPMAP_COMMENT)
          contents.insert(index+2, APPMAP_RAILTIE)
          break
        end
        if line =~ /railties/ && (not contents[index+1] =~ /railties/)
          contents.insert(index+1, "\n" + APPMAP_COMMENT)
          contents.insert(index+2, APPMAP_RAILTIE)
          break
        end
      end
      File.open('config/application.rb', 'w') do |f|
        contents.each { |line| f.puts(line) }
      end
      puts "appmap/railties dependency added successfully".green
    end
  end

end

# main
worker = DependencyInjection.new(Dir.getwd)
worker.generate_all_dependencies
