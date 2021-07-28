class CreateSurvivors < ActiveRecord::Migration[6.1]
  def change
    create_table :survivors do |t|
      t.string :name
      t.integer :age
      t.string :gender
      t.string :last_pos_latitude
      t.string :last_pos_longitude
      t.integer :infected_count

      t.timestamps
    end
  end
end
