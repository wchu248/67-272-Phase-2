class CreatePurchases < ActiveRecord::Migration
  def change
    create_table :purchases do |t|
      t.integer :item_id
      t.integer :quantity
      t.date :date

      t.timestamps null: false
    end
  end
end
