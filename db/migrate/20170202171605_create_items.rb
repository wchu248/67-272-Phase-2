class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      t.string :name
      t.text :description
      t.string :category
      t.string :color
      t.float :weight
      t.integer :inventory_level
      t.integer :reorder_level
      t.boolean :active, default: true

      t.timestamps null: false
    end
  end
end
