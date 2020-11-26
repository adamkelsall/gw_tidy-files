# encoding: utf-8

module TF_fp_arguments

  def setup_arguments_validate
    # Validate common folder_pass command line arguments

    @args.process
    @args.validate

    # Directories

    @directories_target  = @args.values("directory") || []
    @directories_target -= [nil]
    @directories_target  = [Dir.pwd] if @directories_target.size.zero?

    @directories_target.map! do |directory|

      directory = directory.gsub("\\", "/")
      directory.chomp!("/") unless directory[-2] == ":"
      directory[0] = directory[0].downcase

      if File.directory?(directory)
        directory
      else
        error_out( 1, "The --directory is not a valid directory:", directory )
      end

    end

  end


  def setup_arguments_validate_status
    # Validate status script specific arguments

    # Recursive / Subdirectories

    return if !@args.called?("breakdown") || @args.called?("recursive")

    error_out( 1, "The --subdirectories argument cannot be used without --recursive." )

  end

end
