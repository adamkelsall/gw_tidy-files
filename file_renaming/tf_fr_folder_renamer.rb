#!/usr/bin/env ruby
# encoding: utf-8

class TF_fr_folder_renamer


  def initialize

    require          "fileutils"
    require_relative "modules/tf_fr_utilities"
    extend           TF_fr_utilities

    setup_variables
    setup_utilities
    setup_arguments

    validate_arguments
    validate_arguments_components

    files_get_directory
    files_process_components
    files_rename

  end


  protected

  def setup_variables
    # Initialise class variables to be used by various methods

    # Paths

    @pwd       = File.expand_path(File.dirname(__FILE__))
    @utilities = File.join( @pwd.split("/")[0...-2].join("/"), "gw_utilities" )

    @files                = []
    @components_available = []
    @components_selected  = { pre: nil, mid: nil, suf: nil }

    # Component positions

    @positions = { pre: "Prefix", mid: "Middle", suf: "Suffix" }

  end


  def setup_arguments
    # Define script arguments and apply validation

    @args = GW_arguments.new(ARGV)

    unique_arguments = [
      { short: "d", long: "directory", description: "Rename the contents of this directory. Defaults to current directory.", quantity: -1 },
      { short: "w", long: "windows",   description: "Force Windows-like sorting method." },
      { short: "n", long: "normal",    description: "Force 'normal' sorting method." },
      { short: "r", long: "reverse",   description: "Reverse the applied sorting method" },
      { short: "i", long: "images",    description: "Limit to image files (determined by extension)." },
      { short: "v", long: "videos",    description: "Limit to video files (determined by extension)", }
    ]

    @args.arguments_valid = unique_arguments + components_arguments

  end


  def validate_arguments
    # Provides script-specific argument validation and error messages

    @args.process
    @args.validate

    # --windows and --normal arguments are mutually exclusive

    if @args.called?("windows") && @args.called?("normal")
      error_out( 1, "--windows and --normal arguments are mutually exclusive." )
    end

    # --directory must be a valid directory

    @directory = @args.values("directory").first || Dir.pwd

    error_out( 1, "The --directory argument is not a valid directory path." ) unless File.directory?(@directory)

  end


  def files_get_directory
    # Generates a list of files in the specified directory
    # Applies sorting methods as specified

    # Get directory files

    files = directory_contents( @directory, levels: 1, error: true )

    # Apply pictures/video exclusivity

    images = %w(bmp exif gif jpg jpeg png raw tif tiff)
    videos = %w(3gp avi flv m4v mkv mov mp4 mpg mpeg qt webm wmv)

    valid_extensions  = []
    valid_extensions += images if @args.called?("images")
    valid_extensions += videos if @args.called?("videos")

    unless valid_extensions.empty?

      files.select! do |file|
        valid_extensions.include?(file.split(".").last)
      end

    end

    # Create a new instance of TF_fr_file for each file path

    @files = files_sorted(files).map { |file| TF_fr_file.new(file) }

  end


  def files_process_components
    # Applies component methods to get / set components for each file

    @components_selected.each do |_part, component|

      next unless component

      @files = component.get_components(@files)
      @files = component.set_components(@files)

    end

  end


  def files_rename
    # Assembles file components and renames all files

    # Rename each file to its temporary name

    @files.each do |file|

      FileUtils.mv( file.file_path, File.join(@directory, file.temp) )

    end

    # Construct new file name and rename

    @files.each do |file|

      new_name = File.join( @directory, format( "%s.%s", file.components.values.join, file.extension ) )

      FileUtils.mv( File.join(@directory, file.temp), new_name )

    end

    # Output completion message

    puts "", format( "%s file%s renamed.", thousands(@files.size), plural(@files.size) )

  end


  def files_sorted( files )
    # Sorts directory files using either windows or normal methods
    # IN  files           Array     Absolute filepaths to be sorted
    # OUT                 Array     Sorted filepaths sorted in the determined method

    # Sort method is specified as an argument

    return windows_sort(files) if @args.called?("windows")
    return files.sort          if @args.called?("normal")

    windows = windows_sort(files)
    normal  = files.sort

    # No action required if no discrepancies

    return windows if windows == normal

    # Discrepancies presnet - ask user to choose

    puts  "", "A sorting method has not been specified and this directory requires one."
    print "Select either Windows-style [W] or 'normal' sorting [n]: "

    $stdin.gets.strip.downcase == "w" ? windows : normal

  end


end

init = TF_fr_folder_renamer.new
exit(0)
