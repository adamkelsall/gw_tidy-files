#!/usr/bin/env ruby
# encoding: utf-8

class TF_fp_complete
  
  def initialize

    require "fileutils"
    
    setup_variables
    setup_requirements
    setup_utilities_initialize
    setup_arguments_validate

    persistent_validate

    directories_target_recursive(true) if @args.called?("recursive")

    complete_directories
    complete_output
    
  end


  def setup_variables
    # Initialize class variables to be used throughout

    # Paths

    @pwd        = File.expand_path(File.dirname(__FILE__))
    @persistent = File.join( @pwd, "persistent" )
    @logs       = File.join( @pwd, "persistent", "logs" )

    @tidy_files = File.join( @pwd.split("/")[0...-1].join("/") )
    @utilities  = File.join( @pwd.split("/")[0...-2].join("/"), "gw_utilities" )

  end

  
  def setup_requirements
    # Validates and requires gw_utilities repository

    # Ensure gw_utilities exists on this repo's level

    unless File.directory?(@utilities)

      puts "ERROR: The gw_utilities repository cannot be found."
      puts "       Ensure it exists in the same directory as gw_ruby_misc."
      exit(1)

    end

    # Require / extend everything in gw_utilities and gw_tidy-files

    [@utilities, @tidy_files, @pwd].each do |directory|
      %w(classes modules).each do |type|

        type_path = File.join( directory, type, "*" )
        Dir.glob(type_path).each do |file|

          require file

          if type == "modules"
            file = file.split("/").last.sub(/^[a-z]+/) { |s| s.upcase }.chomp(".rb")
            extend Object.const_get(file)
          end

        end

      end
    end

  end


  def setup_utilities_initialize
    # Initialize required classes

    # GW Utilities : Arguments class

    @args = GW_arguments.new(ARGV)

    @args.arguments_valid = [
      { short: "d", long: "directory", description: "One or more directories to execute on. Defaults to the current directory." },
      { short: "r", long: "recursive", description: "Also executes on all directories below the specified directory." }
    ]

  end


  def complete_directories
    # Sets the targeted directories as complete in the persistent/directories file
    # Does not complete targeted directories which are not already present

    persistent_directories_read

    # Complete directories

    stats_before = directories_persistent_status

    directories_target_process(true)

    stats_after = directories_persistent_status

    # Generate output lines for directory status changes
    # Directories completed : 5 ( 10 => 15 )

    @output_lines = []

    @output_lines << [
      "Directories completed",
      format(
        "%s ( %s => %s )",
        thousands( stats_after[:complete] - stats_before[:complete] ),
        thousands( stats_before[:complete] ),
        thousands( stats_after[:complete] )
      )
    ]

    persistent_directories_write
    
  end


  def complete_output
    # Generate log files and write command line output

    # Generate log files

    log_write_daily

    # Command line output

    dividers = [ "", " : " ]

    puts "", column_format( @output_lines, dividers )

  end
  
end

init = TF_fp_complete.new
exit(0)
