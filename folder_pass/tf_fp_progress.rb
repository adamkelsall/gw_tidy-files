#!/usr/bin/env ruby
# encoding: utf-8

class TF_fp_progress
  
  def initialize

    require "fileutils"
    
    setup_variables
    setup_requirements
    setup_utilities_initialize
    setup_arguments_validate

    persistent_validate

    progress_directory
    progress_output

  end


  def setup_variables
    # Initialize class variables to be used throughout

    # Paths

    @pwd        = File.expand_path(File.dirname(__FILE__))
    @persistent = File.join( @pwd, "persistent" )

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

  end


  def progress_directory
    # Gets persistent directories and creates progress lines

    persistent_directories_read
    progress = directories_persistent_status

    @output_lines = []

    # Generate progress line

    progress.each do |status, quantity|

      percentage = format( "%0.1f%", ( quantity.to_f / progress[:total] ) * 100 )

      @output_lines << [
        status.capitalize,
        thousands(quantity),
        status == :total ? "" : percentage
      ]

    end

  end


  def progress_output
    # Outputs progress lines

    # Right-align percentages

    percentage_width = @output_lines.map { |line| line.last.size }.sort.last

    @output_lines.map! do |line|
      line[-1] = format("%#{percentage_width}s", line[-1] )
      line
    end

    # Column formatting and output

    spacers = [ "", " : ", " / ", "" ]

    @output_lines = column_format( @output_lines, spacers )

    @output_lines.first.chomp!        # gwr_column.rb does not remove " / " from end of first row
    @output_lines.first.chomp!(" /")  # Requires rework for column_format's all_spacers argument

    puts "", @output_lines

  end

end

init = TF_fp_progress.new
exit(0)
