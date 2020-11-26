# encoding: utf-8

class TF_fr_component

  # Parent class for components
  # Allows components to be interchanged on each execution
  # This class provides common methods used by all components

  attr_reader   :position     # Symbol  Whether this component's position is :pre, :mid or :suff
  attr_reader   :short        # String  Short argument to call to use this component
  attr_reader   :long         # String  Long argument to call to use this component
  attr_reader   :description  # String  Description shown for this argument in GW Arguments help
  attr_reader   :quantity     # Fixnum  Represents how many argument values can be specified

  SUBCLASSES = []             # Array   Classes that inherit TF_fr_component


  def self.inherited(subclass)
    # Triggers whenever this class is inherited
    # Add the subclass to an Array of accessible subclasses

    SUBCLASSES << subclass

  end


  def get_argument
    # Returns each argument as a GW Arguments-ready Hash
    # OUT                 Hash      Hash containing component arguments

    position_names = { pre: "prefix", mid: "middle", suf: "suffix" }

    {
      short:       @short,
      long:        @long,
      description: format( "Component %s: %s", position_names[@position], @description ),
      quantity:    @quantity
    }

  end


  def process_arguments( values )
    # Converts any argument values for this component from GW Arguments
    # IN  values          Array     Values excluding nil "valueless" calls

    # Default inherited method - do nothing

  end


  def get_components( files )
    # Attempts to find valid component strings in the files Array
    # If found these are separated and stored in the file instance
    # IN  files            Array    TF_fr_file instances to find component strings of
    # OUT                  Array    TF_fr_file instances with modified component strings

    # Default version of this class method - make no changes

    files

  end


  def set_components( files )
    # Generate new component strings for each file based on file names
    # IN  files             Array    TF_fr_file instances to generate component strings for
    # OUT                   Array    TF_fr_file instances with modified component strings

    # Default version of this class method - make no changes

    files

  end


  protected

  def invalid_value( value )
    # Errors out with a standardised invalid argument value message
    # IN  value             String   Argument value that is invalid

    extend GW_error
    error_out( 1, format( "Invalid argument value for component '%s':", @long ), value )

  end


end
