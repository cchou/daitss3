class CreateAccounts < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
      t.String :id
      t.Text :descripton
      t.String :report_email

    end
  end
end
