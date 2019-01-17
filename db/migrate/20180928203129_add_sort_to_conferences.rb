class AddSortToConferences < ActiveRecord::Migration[5.2]
  def change
    add_column :conferences, :sort, :integer, default: 999999
  end
end
