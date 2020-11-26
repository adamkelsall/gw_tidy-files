# encoding: utf-8

module TF_fp_directories

  def directories_persistent_status( filter = [] )
    # Provide added / completed count of @directories_persistent
    # IN  filter          Array     When specified, only these directories are included
    # OUT                 Hash      Complete / uncomplete / total count

    directories = 
      if filter.empty?
        @directories_persistent
      else
        @directories_persistent.select { |directory, _status| filter.include?(directory) }
      end

    status = {}

    status[:total]      = directories.size
    status[:complete]   = directories.values.select { |status| status }.size
    status[:uncomplete] = status[:total] - status[:complete]

    status

  end


  def directories_target_recursive( complete = false )
    # Adds all subdirectories to directories listed in @directories_target
    # IN  complete        boolean   Whether to also include listed directories

    blacklist = persistent_blacklist_read

    # Recursive directories

    directories_recursive = []

    @directories_target.each do |directory|
      directories_recursive += directory_contents(
        directory,
        blacklist:   blacklist,
        files:       false,
        directories: true
      )
    end

    # Persistent directories

    if complete

      persistent_directories_read

      @directories_target.each do |directory|

        directory << "/"
        directories_recursive += @directories_persistent.keys.select { |dir| dir.start_with?(directory) }

      end

    end

    @directories_target += directories_recursive
    @directories_target  = @directories_target.flatten.sort

  end


  def directories_target_process( mode )
    # Adds / completes @directories_target in @directories_persistent
    # Creates @log_lines array for each modified directory status
    # IN  mode            Boolean   true = complete; false = add

    @log_lines = []
    now        = Time.now.to_i

    @directories_target.each do |directory|

      status = @directories_persistent[directory]

      next if status == mode
      next if status.nil? && mode

      action =
        if mode
          "complete"
        else
          status ? "reset" : "add"
        end

      @directories_persistent[directory] = mode

      @log_lines << [ now, action, directories_persistent_status.values, directory ].flatten

    end

  end

end
