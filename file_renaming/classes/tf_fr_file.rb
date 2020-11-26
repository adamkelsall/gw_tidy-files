# encoding: utf-8

class TF_fr_file

  # Provides a structured class for storing each file being modified
  # Allows the original and new (modified) file name to be referenced
  # Provides storage for individual component part strings

  attr_accessor :components  # Hash     Component instances to be used for each component part
  attr_reader   :extension   # String   Formatted file type extension of the file
  attr_reader   :file_path   # String   Absolute file path to allow querying the file itself
  attr_accessor :modified    # String   File name after components modification
  attr_reader   :original    # String   File name before components modification
  attr_reader   :temp        # String   Interim filename to avoid renaming conflicts


  def initialize( file_path )
    # Convert absolute filepath into basic pieces

    extend GW_directory

    @components = { pre: "", mid: "", suf: "" }

    # Assign class variables from initialisation arguments
    # Watch out for shallow copying!

    @file_path = file_path
    @original  = directory_parts( file_path, -1 )

    @modified  = "" << @original
    @extension = "" << @original[/\.([a-z0-9]{1,5})$/, 1].to_s.downcase

    @temp      = "gw_tidy-files_TEMP_" << @original

  end


end
