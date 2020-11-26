#!/usr/bin/env ruby
# encoding: utf-8

class TF_fp_status
  
  def initialize

    require "fileutils"
    
    setup_variables
    setup_requirements
    setup_utilities_initialize
    setup_arguments_validate
    setup_arguments_validate_status

    persistent_validate

    status_directory
    status_recursive if @args.called?("recursive")
    status_breakdown if @args.called?("breakdown")
    status_output

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

    @args.arguments_valid = [
      { short: "d", long: "directory", description: "One or more directories to execute on. Defaults to the current directory." },
      { short: "r", long: "recursive", description: "Also executes on all directories below the specified directory." },
      { short: "b", long: "breakdown", description: "Shows stats for each subdirectory below target directory." }
    ]

  end


  def status_directory
    # Display the status of the target directory. Default behaviour

    @directory = @directories_target.first

    persistent_directories_read

    status =
      case @directories_persistent[@directory]
      when true  then "Complete"
      when false then "Uncomplete"
      when nil   then "Unlisted"
      end

    @output_lines = []
    @output_lines << [ "This directory", status ]

  end


  def status_recursive
    # Displays an overview of all directories below the target

    # Get directories and compile their status

    directories_target_recursive

    status = directories_persistent_status(@directories_target)

    unlisted = @directories_target.size - status[:total]

    status_lines = [
      [ "unlisted",   unlisted ],
      [ "uncomplete", status[:uncomplete] ],
      [ "complete",   status[:complete] ]
    ]

    # Write output lines

    status_lines.each do |line|

      percentage = format( "%0.1f%", ( line.last / @directories_target.size.to_f ) * 100 )

       @output_lines << [
         format( "Directories %s", line.first ),
          [ thousands(line.last), percentage ],
       ]

    end

  end


  def status_breakdown
    # Displays one line per subdirectory of target directory
    # Includes the subdirectory's status and that of its contents (if any)

    @output_lines << [ "Subdirectories breakdown", "un[L]isted / [U]ncomplete / [C]omplete" ]

    # List subdirectories

    depth          = @directory.split("/").size
    subdirectories = @directories_target.select { |dir| dir.split("/").size == depth + 1 }

    # Iterate subdirectories

    subdirectories.sort.each do |subdirectory|

      contents = @directories_target.select { |dir| dir.start_with?(subdirectory) } - [subdirectory]

      # Output status line

      @output_lines << format(
        "%s : %s : %s",
        status_char( [@directories_persistent[subdirectory]], "" ),
        status_char( contents.map { |content| @directories_persistent[content] }, "-" ),
        subdirectory.split("/").last
      )

    end

  end


  def status_output
    # Applies column formatting to @output_lines and outputs (puts)

    # Apply number / percentage column formatting

    if @args.called?("recursive")

      spacers = [ "", " / ", "" ]

      percentage_cells   = @output_lines[1..3].map { |row| row.last }
      percentage_spacing = percentage_cells.map { |cell| cell.last.size }.sort.last
      percentage_cells.map! { |cell| [ cell.first, format("%#{percentage_spacing}s", cell.last) ] }

      percentage_cells = column_format( percentage_cells, spacers )
      
      percentage_cells.each_with_index do |cell, index|
        @output_lines[index + 1][-1] = cell
      end

    end

    # Apply overall column formatting

    spacers = [ "", " : ", "" ]

    @output_lines[0..4] = column_format( @output_lines[0..4], spacers )

    # Output lines with line breaks

    @output_lines.each_with_index do |line, index|

      puts "" if [0, 1, 4, 5].include?(index)
      puts line

    end

  end


  def status_char( statuses, none_char )
    # Converts array of directory statuses to string of corresponding characters
    # Outputs a status character if included in the status array, none_char if not
    # IN  statuses        Array     List of statuses to check against
    # IN  none_char       String    Character to display if the status is not found
    # OUT                 String    Character representation of each status occurence

    output     = ""
    characters = { nil => "L", false => "U", true => "C" }

    characters.each do |status, char|
      output << ( statuses.include?(status) ? char : none_char )
    end

    output

  end

end

init = TF_fp_status.new
exit(0)
