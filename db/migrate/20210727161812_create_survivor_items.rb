class CreateSurvivorItems < ActiveRecord::Migration[6.1]
  def change
    create_table :survivor_items do |t|
      t.references :survivor, null: false, foreign_key: true
      t.references :item, null: false, foreign_key: true
      t.integer :item_count

      t.timestamps
    end
  end
end
