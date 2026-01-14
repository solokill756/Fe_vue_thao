# frozen_string_literal: true

class AddQrCodeToTeachers < ActiveRecord::Migration[7.0]
  def change
    add_column :teachers, :qr_code, :string
    add_index :teachers, :qr_code, unique: true
  end
end

