# encoding: utf-8

module TF_fp_logs

  def log_write_daily
    # Writes the daily log CSV lines for the action(s) performed

    return if @log_lines.empty?

    daily_log = File.join( @pwd, "persistent", "logs", Time.now.strftime("%Y-%m-%d") << ".csv" )

    csv_lines = []

    # New daily log file

    unless File.file?(daily_log)

      csv_lines << "Timestamp,Action,Total,Complete,Uncomplete,Directory"
      @output_lines << [ "File Created", daily_log.sub(@pwd, "")[1..-1] ]
      log_write_summary

    end

    # Convert log line to CSV formatted line

    @log_lines.each do |line|

      csv_lines << line.join(",").sub(line[-1], "\"#{line[-1]}\"" )

    end

    # Write CSV lines to file

    file_write( daily_log, "a", csv_lines )

  end
  

  def log_write_summary
    # Takes the last daily log CSV line and adds quantities to summary.csv

    logs_directory = File.join( @pwd, "persistent", "logs" )
    summary        = File.join( logs_directory, "summary.csv" )

    # Find previous daily log

    logs = Dir.entries(logs_directory).select { |file| file[/[\d-]{10}\.csv$/] }

    return if logs.empty?

    last_log = File.join( logs_directory, logs.sort.last )

    # Generate summary.csv lines

    last_line    = file_read( last_log, {empty_lines: false, whitespace: false} ).last.split(",")
    last_line[0] = last_log.split("/").last.sub(".csv", "")
    last_line    = last_line.values_at(0, 2..4)

    summary_lines = []
    summary_lines << "Date,Total,Complete,Uncomplete" unless File.file?(summary)
    summary_lines << last_line.join(",")

    @output_lines << [ "File Created", summary.sub(@pwd, "")[1..-1] ] unless File.file?(summary)

    # Write summary.csv lines

    file_write( summary, "a", summary_lines )

  end

end
