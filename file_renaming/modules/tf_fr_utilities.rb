# encoding: utf-8

module TF_fr_utilities


  def setup_utilities
    # Validates and requires gw_utilities repository

    # Ensure gw_utilities exists on this repo's level

    unless File.directory?(@utilities)

      puts "ERROR: The gw_utilities repository cannot be found."
      puts "       Ensure it exists in the same directory as gw_ruby_misc."
      exit(1)

    end

    # Require / extend everything in gw_utilities

    [@utilities, @pwd].each do |directory|
      %w(classes modules).each do |type|

        type_path = File.join( directory, type, "*" )
        Dir.glob(type_path).each do |file|

          require file

          if type == "modules"
            file = file.split("/").last.sub( /^[a-z]+/, &:upcase ).chomp(".rb")
            extend Object.const_get(file)
          end

        end

      end
    end

  end


end
