#!/usr/bin/env ruby
# encoding: utf-8

class TF_fp_add
  
  def initialize

    require "fileutils"
    
    setup_variables
    setup_requirements
    setup_utilities_initialize
    setup_arguments_validate

    persistent_validate

    directories_target_recursive if @args.called?("recursive")

    add_directories
    add_output
    
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


  def add_directories
    # Adds the targeted directories to the persistent/directories file
    # Also changes completed directories back to uncompleted

    persistent_directories_read

    # Add directories

    stats_before = directories_persistent_status

    directories_target_process(false)

    stats_after = directories_persistent_status

    # Generate output lines for directory status changes
    # Directories added : 5 ( 10   => 15   )
    # Directories reset : 2 ( 3/10 => 1/15 )

    @output_lines = []

    @output_lines << [
      "Directories added",
      [
        thousands( stats_after[:total] - stats_before[:total] ),
        thousands( stats_before[:total] ),
        thousands( stats_after[:total] )
      ]
    ]

    if stats_after[:complete] < stats_before[:complete]

      @output_lines << [
        "Directories reset",
        [
          thousands( stats_before[:complete] - stats_after[:complete] ),
          format( "%d/%d", thousands(stats_before[:complete]), thousands(stats_before[:total]) ),
          format( "%d/%d", thousands(stats_after[:complete]), thousands(stats_after[:total]) )
        ]
      ]

    end

    persistent_directories_write

  end


  def add_output
    # Generate log files and write command line output

    # Generate log files

    log_write_daily

    # Command line output
    # Process transition substrings

    transitions_dividers = [ "", " ( ", " => ", " )" ]

    transitions = @output_lines.map { |line| line[1] if line[1].class == Array } - [nil]
    transitions = column_format( transitions, transitions_dividers, true )

    transitions.each_with_index do |substring, index|

      @output_lines[index][1] = substring

    end

    # Process output lines

    dividers = [ "", " : " ]

    puts "", column_format( @output_lines, dividers )

  end
  
end

init = TF_fp_add.new
exit(0)
