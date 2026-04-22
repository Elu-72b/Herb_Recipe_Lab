class ChangeFlavorColumnsInDrinkingLogs < ActiveRecord::Migration[7.2]
  def change
    remove_column :drinking_logs, :savory, :integer if column_exists?(:drinking_logs, :savory)
    add_column :drinking_logs, :flowery, :integer, default: 0 unless column_exists?(:drinking_logs, :flowery)
  end
end
