class RenameFeePerSessionToMonthlyTuitionFeeInClasses < ActiveRecord::Migration[7.0]
  def up
    # Copy data from fee_per_session to monthly_tuition_fee if monthly_tuition_fee is null
    execute <<-SQL
      UPDATE classes
      SET monthly_tuition_fee = fee_per_session
      WHERE monthly_tuition_fee IS NULL AND fee_per_session IS NOT NULL
    SQL
    
    # Remove fee_per_session column
    remove_column :classes, :fee_per_session if column_exists?(:classes, :fee_per_session)
  end

  def down
    # Add fee_per_session back
    add_column :classes, :fee_per_session, :decimal, precision: 15, scale: 2 unless column_exists?(:classes, :fee_per_session)
    
    # Copy data back
    execute <<-SQL
      UPDATE classes
      SET fee_per_session = monthly_tuition_fee
      WHERE fee_per_session IS NULL AND monthly_tuition_fee IS NOT NULL
    SQL
  end
end
