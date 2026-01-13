class AddCloudinaryFieldsToSubmissions < ActiveRecord::Migration[7.0]
  def change
    add_column :submissions, :cloudinary_id, :string
    add_column :submissions, :resource_type, :string
  end
end
