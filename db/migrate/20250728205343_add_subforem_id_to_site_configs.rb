class AddSubforemIdToSiteConfigs < ActiveRecord::Migration[7.0]
  def change
    unless column_exists?(:site_configs, :subforem_id)
      add_column :site_configs, :subforem_id, :integer, default: 0, null: false
    end
  end
end
