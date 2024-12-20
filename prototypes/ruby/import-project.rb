# Ruby Port of the Shell/Bash Script
def display_message(message: '', prefix: '', suffix: '', verbose: true)
  puts "#{prefix}#{message}#{suffix}" if verbose
end

def warning(message: '', error_id: nil, verbose: true)
  display_message(message: message, prefix: 'Warning: ', verbose: verbose)
  exit(error_id) if error_id
end

def newline(verbose: true)
  puts if verbose
end

def import_config(config_file, verbose: true)
  config_file += '.json' unless config_file.end_with?('.json')
  unless File.exist?(config_file)
    warning(message: "Configuration file #{config_file} is missing!", error_id: 1, verbose: verbose)
  end

  config = JSON.parse(File.read(config_file))
  config.each { |key, value| ENV[key] = value.to_s }

  display_message(message: "Imported configuration from #{config_file}", verbose: verbose)
end

def apply_transformations(config_file, target_dir, verbose: true)
  config = JSON.parse(File.read(config_file))

  config.each do |filename, replacements|
    target_file = File.join(target_dir, filename)
    unless File.exist?(target_file)
      warning(message: "Target file #{target_file} does not exist!", verbose: verbose)
      next
    end

    # Read the content of the file
    content = File.read(target_file)

    # Apply replacements
    replacements.each do |placeholder, value|
      content.gsub!("${#{placeholder}}", value)
    end

    # Write the updated content back to the file
    File.write(target_file, content)

    display_message(message: "Applied transformations to #{target_file}", verbose: verbose)
  end
end

def setup_project_structure(source_dir, destination_dir, verbose: true)
  unless Dir.exist?(source_dir)
    warning(message: "Source directory #{source_dir} does not exist!", error_id: 2, verbose: verbose)
  end

  if Dir.exist?(destination_dir)
    FileUtils.rm_rf(destination_dir)
  end

  FileUtils.cp_r(source_dir, destination_dir)
  display_message(message: "Copied project structure from #{source_dir} to #{destination_dir}", verbose: verbose)
end

def parse_arguments
  require 'optparse'

  options = {}
  OptionParser.new do |opts|
    opts.banner = "Usage: script.rb [options]"

    opts.on("--config CONFIG", "Configuration file") { |v| options[:config] = v }
    opts.on("--target-dir DIR", "Target directory for transformations") { |v| options[:target_dir] = v }
    opts.on("--source-dir DIR", "Source directory for project structure") { |v| options[:source_dir] = v }
    opts.on("--destination-dir DIR", "Destination directory for project setup") { |v| options[:destination_dir] = v }
    opts.on("--verbose", "Enable verbose output") { options[:verbose] = true }
  end.parse!

  options
end

def main
  args = parse_arguments

  # Import environment variables from the configuration file
  import_config(args[:config], verbose: args[:verbose])
  newline(verbose: args[:verbose])

  # Set up project structure
  setup_project_structure(args[:source_dir], args[:destination_dir], verbose: args[:verbose])
  newline(verbose: args[:verbose])

  # Apply transformations to files in the target directory
  apply_transformations(args[:config], args[:target_dir], verbose: args[:verbose])
  newline(verbose: args[:verbose])
end

if __FILE__ == $0
  require 'json'
  require 'fileutils'
  main
end
