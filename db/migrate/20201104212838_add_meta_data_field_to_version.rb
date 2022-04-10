class AddMetaDataFieldToVersion < ActiveRecord::Migration[5.2]
  def change
    add_column :versions, :meta_data, :jsonb, default: {}
  end
end
