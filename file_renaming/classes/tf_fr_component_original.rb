# encoding: utf-8

class TF_fr_component_original < TF_fr_component

  # Component class: original (post)
  # Uses the original file name as its suffix
  # Excludes file extension


  def initialize
    # Create attr_reader class variables

    @short       = "O"
    @long        = "original"
    @description = "The original filename excluding file extension"
    @position    = :suf

  end


  def get_components( files )
    # Attempts to find valid component strings in the files Array
    # If found these are separated and stored in the file instance
    # IN  files            Array    TF_fr_file instances to find component strings of
    # OUT                  Array    TF_fr_file instances with modified component strings

    # Remove file prefixes (valid or not)

    files.each do |file|

      suffix = " " << file.original
      suffix.sub!(/\.#{file.extension}$/, "") unless file.extension.empty?

      file.components[:suf] = suffix
      file.modified         = ""

    end

  end


  def set_components( files )
    # Generate new component strings for each file based on file names
    # IN  files             Array    TF_fr_file instances to generate component strings for
    # OUT                   Array    TF_fr_file instances with modified component strings

    # Set prefix component based on @extensions Hash keys

    files.each do |file|

      suffix = " " << file.original
      suffix.sub!(/\.#{file.extension}$/, "") unless file.extension.empty?

      file.components[:suf] = suffix

    end

  end


end
