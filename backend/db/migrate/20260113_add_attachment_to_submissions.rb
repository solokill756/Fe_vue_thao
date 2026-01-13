class AddAttachmentToSubmissions < ActiveRecord::Migration[7.0]
  def change
    # Add storage reference column for ActiveStorage
    add_column :submissions, :file_name, :string unless column_exists?(:submissions, :file_name)
    
    # Remove Cloudinary columns as we'll no longer need them
    remove_column :submissions, :cloudinary_id, :string if column_exists?(:submissions, :cloudinary_id)
    remove_column :submissions, :resource_type, :string if column_exists?(:submissions, :resource_type)
  end
end
