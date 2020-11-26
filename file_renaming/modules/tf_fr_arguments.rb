# encoding: utf-8

module TF_fr_arguments


  def components_arguments
    # Creates a GW arguments argument for each component class
    # Uses data stored in TF_fr_component's constant

    # Initialise all components for current/future use

    @components_available = TF_fr_component::SUBCLASSES.map { |comp| comp.new }

    # Sort instanced components by which position they are

    @components_available.sort! do |x, y|

      xpos, ypos =
        [x, y].map do |z|
          @positions.keys.index( z.position )
        end

      position = xpos <=> ypos
      position.zero? ? x.long <=> y.long : position

    end

    # Assemble arguments hash and return

    @components_available.map { |comp| comp.get_argument }

  end


  def validate_arguments_components
    # Ensures that there are no more than 1 component per position

    @components_available.each do |component|

      long     = component.long
      position = component.position

      next unless @args.called?(long)

      # Validate component position and store for further use

      if @components_selected[position]

        error_out( 1,
          "Only 1 component can be specified per component position:",
          format( "%s: %s & %s", @positions[position], long, @components_selected[position].long )
        )

      end

      @components_selected[position] = component

    end

    # Mid component must not be empty - default to numeric

    @components_selected[:mid] ||= @components_available.select { |comp| comp.is_a?(TF_fr_component_numeric) }.first

    # Provide GW Arguments values to each component

    @components_selected.each do |position, component|

      puts format( "%s: %s", @positions[position], component ? component.long.capitalize : "None" )

      next unless component
      component.process_arguments( @args.values(component.long) )

    end

  end


end
