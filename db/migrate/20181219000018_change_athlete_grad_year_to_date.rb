class ChangeAthleteGradYearToDate < ActiveRecord::Migration[5.2]
  def up
    rename_column :athletes, :graduation_year, :grad_year
    add_column :athletes, :graduation_year, :date
  end

  def down
    remove_column :athletes, :graduation_year
    add_column :athletes, :graduation_year, :string
  end
end
