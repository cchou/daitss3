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
  
  
end
