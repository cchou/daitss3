module WorkspaceHelper
  def idle_wips
    @wips.find_all { |w| w.state == :idle }
  end
  
  def active_wips
    @wips.length - idle_wips.length
  end
  
  def throttle_string
    "#{throttles(:ingest)} #{throttles(:dissemination)} #{throttles(:refresh)} #{throttles(:withdrawal)} "
  end
  
  def throttles type
    case type
    when :ingest;           archive.ingest_throttle        != 1 ? "#{archive.ingest_throttle} ingests;"               : "1 ingest;"
    when :dissemination;    archive.dissemination_throttle != 1 ? "#{archive.dissemination_throttle} disseminations;" : "1 dissemination;"
    when :withdrawal;       archive.withdrawal_throttle    != 1 ? "#{archive.withdrawal_throttle} withdrawals;"       : "1 withdrawal;"
    when :refresh;          archive.refresh_throttle       != 1 ? "#{archive.refresh_throttle} refreshes;"            : "1 refresh;"
    else ; "huh?"
    end
  end
  
  def space
    'workspace'
  end
  
  def running?
    archive.workspace.select(&:running?).size
  end
  
  def total
    idle_wips.inject(0) {|sum, w| sum + Sip.first(:package_id => w.id).size_in_bytes }
  end
  
  def total_to_s
    if total > 1_000_000_000_000
      sprintf("%5.2f TB",  total / 1_000_000_000_000.0)
    elsif total > 1_000_000_000
      sprintf("%5.2f GB",  total / 1_000_000_000.0)
    elsif total > 1_000_000
      sprintf("%5.2f MB",  total / 1_000_000.0)
    elsif total > 1_000
      sprintf("%5.2f KB",  total / 1_000.0)
    else
      sprintf("%5.2f B",   total)
    end
  end
  
  def total_files
    idle_wips.inject(0) {|sum, w| sum + Sip.first(:package_id => w.id).number_of_datafiles }
  end
  
  def ingest_count
    count = 0
    idle_wips.each { |w| count += 1 if w.task == :ingest }
    count
  end
  
  def disseminate_count
    count = 0
    idle_wips.each { |w| count += 1 if w.task == :disseminate }
    count
  end
  
  def withdraw_count
    count = 0
    idle_wips.each { |w| count += 1 if w.task == :withdraw }
    count
  end
  
  def refresh_count
    count = 0
    idle_wips.each { |w| count += 1 if w.task == :refresh }
    count
  end
  
  def peek_count
    count = 0
    idle_wips.each { |w| count += 1 if w.task == :peek }
    count
  end
  
  
  
end
