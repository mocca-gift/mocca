class AddCompanyNameToGifts < ActiveRecord::Migration
  def change
    add_column :gifts, :company_name, :string
  end
end
