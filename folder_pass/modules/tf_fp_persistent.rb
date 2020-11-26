# encoding: utf-8

module TF_fp_persistent

  def persistent_validate
    # Ensure the persistent folder and its files exist

    # Folders

    folders = [
      File.join( @pwd, "persistent" ),
      File.join( @pwd, "persistent", "logs")
    ]

    folders.each { |folder| FileUtils.mkdir(folder) unless File.directory?(folder) }

    # File - directories

    file_directories = File.join( @persistent, "directories" )
    FileUtils.touch(file_directories) unless File.file?(file_directories)

    # File - blacklist

    file_blacklist = File.join( @persistent, "blacklist" )

    return if File.file?(file_blacklist)

    file_write(
      file_blacklist, "w",
      "# List of regular expressions used as part of the --recursive argument.",
      "# Directories that match these expressions are not listed or searched."
    )

    error_out( 1,
      "The 'folder_pass/persistent/blacklist' file did not exist and has been created.",
      "Please populate it with expressions to be excluded when using the --recursive argument."
    )

  end


  def persistent_blacklist_read
    # Reads the blacklist and returns an evaluated array of Regexps

    blacklist         = []
    blacklist_strings = file_read(
      File.join(@pwd, "persistent", "blacklist"),
      { comment: "#", empty_lines: false, whitespace: false }
    )

    blacklist_strings.each do |regex|

      fail regex unless regex[/\/.*\/[imxo]*/i]

      blacklist << eval(regex)

    end

    return blacklist

  rescue SyntaxError => e

    error_out( 1, "Syntax error(s) found while evaluating 'persistent/blacklist' file." )

  rescue StandardError => e

    error_out( 1, "The following expression in 'persistent/blacklist' is invalid:", e.message )

  end


  def persistent_directories_read
    # Read persistent/directories into a hash with status indicated

    @directories_persistent = {}

    directories_lines = file_read(
      File.join(@pwd, "persistent", "directories"),
      { comment: "#", empty_lines: false, whitespace: false }
    )

    directories_lines.each do |directory|

      status = directory[0] == "1"
      path   = directory[/^..(.*)/, 1]

      @directories_persistent[path] = status

    end

  end


  def persistent_directories_write

    directories_lines = []

    @directories_persistent.each do |path, status|

      directories_lines << format( "%s %s", status ? "1" : "0", path )

    end

    file_write(
      File.join(@pwd, "persistent", "directories"),
      "w", directories_lines
    )

  end

end
