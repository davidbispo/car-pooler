class CreateCarsTable < ActiveRecord::Migration[6.1]
  def change
    create_table :cars do |t|
      t.integer :seats
      t.timestamps
    end
    
    add_index :cars, :seats
  end
end
