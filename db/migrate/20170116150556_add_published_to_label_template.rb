class AddPublishedToLabelTemplate < ActiveRecord::Migration[5.0]
  def change
    add_column :label_templates, :published, :boolean, default: false
  end
end
