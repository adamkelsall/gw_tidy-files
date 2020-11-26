# encoding: utf-8

class TF_fr_component_filetype < TF_fr_component

  # Component class: Filetype (pre)
  # Prefixes the file with a single capital letter representing file type/group
  # Custom letter designations can be specified as argument values


  def initialize
    # Create attr_reader class variables

    @short       = "F"
    @long        = "filetype"
    @description = "Character representing file type / group (images, videos)."
    @position    = :pre

  end


  def process_arguments( values )
    # Converts any argument values for this component from GW Arguments
    # IN  values          Array     Values excluding nil "valueless" calls

    @extensions = {}

    values.map(&:downcase).each do |value|

      # Convert and validate argument values

      unless value[/^[a-z]=[a-z0-9,]+$/]
        invalid_value(value)
      end

      letter, extensions = value.split("=")
      letter.upcase!
      extensions = extensions.split(",")

      # Set validated values in @extensions

      define_extensions( extensions, letter )

    end

  end


  def get_components( files )
    # Attempts to find valid component strings in the files Array
    # If found these are separated and stored in the file instance
    # IN  files            Array    TF_fr_file instances to find component strings of
    # OUT                  Array    TF_fr_file instances with modified component strings

    # Remove file prefixes (valid or not)

    files.each do |file|

      file.modified[0..1] = "" if file.modified[/^[A-Z]-/]

    end

  end


  def set_components( files )
    # Generate new component strings for each file based on file names
    # IN  files             Array    TF_fr_file instances to generate component strings for
    # OUT                   Array    TF_fr_file instances with modified component strings

    # Set prefix component based on @extensions Hash keys

    files.each do |file|

      if @extensions.key?(file.extension)
        file.components[:pre] = format( "%s-", @extensions[file.extension] )
      end

    end

  end


  protected

  def define_extensions( *extensions, letter )
    # Sets a letter to be associated with one or more extensions
    # Includes recognition for the keywords "images" and "videos"
    # IN  extensions       Array    Extensions to set the associated letter of
    # IN  letter           String   Single character to set for the extensions

    images = %w(bmp exif gif jpg jpeg png raw tif tiff)
    videos = %w(3gp avi flv m4v mkv mov mp4 mpg mpeg qt webm wmv)

    # Expand keywords and prepare Array

    extensions.flatten!

    extensions.map! do |extension|

      case extension
      when "images" then images
      when "videos" then videos
      else extension
      end

    end

    extensions.flatten!

    # Format and set each extension in @extensions

    extensions.each { |extension| @extensions[extension] = letter }

  end


end
