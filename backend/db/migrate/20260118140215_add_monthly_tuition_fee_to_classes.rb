class AddMonthlyTuitionFeeToClasses < ActiveRecord::Migration[7.0]
  def change
    add_column :classes, :monthly_tuition_fee, :decimal, precision: 15, scale: 2
  end
end
