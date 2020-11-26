# encoding: utf-8

class TF_fr_component_numeric < TF_fr_component

  # Component class: Filetype (pre)
  # Prefixes the file with a single capital letter representing file type/group
  # Custom letter designations can be specified as argument values


  def initialize
    # Create attr_reader class variables

    @short       = "N"
    @long        = "numeric"
    @description = "Default zero-padded number representing quantity of similar files."
    @position    = :mid

  end


  def process_arguments( values )
    # Converts any argument values for this component from GW Arguments
    # IN  values          Array     Values excluding nil "valueless" calls

    # Initialise default values

    @digits   = 4
    @grouping = true

    # Set digits / grouping based on argument values

    values.each do |value|

      case

      when !value[/\D/]
        @digits = value.to_i

      when value.start_with?("ungroup")
        @grouping = false

      else
        invalid_value(value)

      end

    end

  end


  def set_components( files )
    # Generate new component strings for each file based on file names
    # IN  files             Array    TF_fr_file instances to generate component strings for
    # OUT                   Array    TF_fr_file instances with modified component strings

    prefixes = {}

    files.each_with_index do |file, index|

      # Create a structure of prefixes for grouping

      prefix   = file.components[:pre]
      original = file.original

      prefixes[prefix] ||= []
      prefixes[prefix]  << original

      # Get the number for the file

      number  = @grouping ? prefixes[prefix].index(original) : index
      number += 1

      # Set zero padded number in components

      file.components[:mid] = format( "%0#{@digits}d", number )

    end

  end


end
