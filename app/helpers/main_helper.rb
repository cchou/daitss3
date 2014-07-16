module MainHelper
  
  def accounts
    Account.user_accounts
  end

  def aip_data
    DataMapper.repository(:default).adapter.select("SELECT project_account_id, SUM(size) AS size, COUNT(*) AS AIP_count, SUM(datafile_count) AS file_count FROM packages INNER JOIN accounts ON packages.project_account_id=accounts.id INNER JOIN aips ON packages.id=aips.package_id INNER JOIN copies ON aips.id=copies.aip_id GROUP BY project_account_id")
  end
  
  def sip_data
    DataMapper.repository(:default).adapter.select("SELECT project_account_id, SUM(size_in_bytes) AS size, COUNT(*) AS SIP_count, SUM(number_of_datafiles) AS file_count FROM packages INNER JOIN accounts ON packages.project_account_id=accounts.id INNER JOIN sips ON packages.id=sips.package_id GROUP BY project_account_id ORDER BY project_account_id")
  end
  
  ##dashboard totals##
  def sip_count
    Sip.count.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
  end
  
  def sip_num_files
    (Sip.sum :number_of_datafiles ).to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
  end
  
  def sip_size
    sprintf('%.2f', Sip.sum(:size_in_bytes).to_f / (1024*1024)).reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
  end
  
  def aip_count
    (Aip.count - Aip.all(:datafile_count  => 0).count - Aip.all(:datafile_count  => nil).count).to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
  end
  
  def aip_num_files
    (Aip.sum :datafile_count).to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
  end
  
  def aip_size
    sprintf('%.2f', Copy.sum(:size).to_f / (1024*1024)).reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
  end
  
  ##account totals##
  def account_id act
    act.project_account_id
  end
  
  def account_sip_count act
    act.sip_count.to_i.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
  end
  
  def account_sip_file_count act
    act.file_count.to_i.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
  end
  
  def account_sip_size act
    sprintf('%.2f', act.size.to_f / (1024*1024)).reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
  end
  
  def account_aip_count act
    act.aip_count.to_i.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
  end
  
  def account_aip_file_count act
    act.file_count.to_i.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
  end
  
  def account_aip_size act
    sprintf('%.2f', act.size.to_f / (1024*1024)).reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
  end
  
  ##user totals##
  def current_user_sip_num
    current_user.packages.sips.all.count.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
  end
  
  def current_user_sip_file_num
    (current_user.packages.sips.all.sum :number_of_datafiles).to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
  end
  
  def current_user_sip_size
    sprintf('%.2f', current_user.packages.sips.all.sum(:size_in_bytes).to_f / (1024*1024)).reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse + " MB" 
  end
  
  def current_user_aip_num
    (current_user.packages.aips.count - current_user.packages.aips.all(:datafile_count => 0).count - current_user.packages.aips.all(:datafile_count => nil).count).to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
  end
  
  def current_user_aip_file_num
    (current_user.packages.aips.all.sum :datafile_count).to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
  end
  
  def current_user_aip_size
    sprintf('%.2f', current_user.packages.aips.copys.all.sum(:size).to_f / (1024*1024)).reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse + " MB"
  end
  
end
