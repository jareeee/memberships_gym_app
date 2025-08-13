class AddAiWeeklyLimitToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :ai_weekly_uses_count, :integer, default: 0, null: false
    add_column :users, :ai_weekly_period_start, :date
  end
end
