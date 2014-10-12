class CreateTables < ActiveRecord::Migration
  def change
    create_table :greetings do |t|
      t.datetime :start_at,   null: false
      t.datetime :end_at,     null: false
      t.integer  :place_id,   null: false
      t.integer  :schedule_id, null: false
      t.string   :raw_place_name, null: false
      t.boolean  :deleted, null: false
    end
    add_index :greetings, :start_at
    add_index :greetings, :place_id, where: 'deleted', name: 'index_greetings_place_id_deleted'
    add_index :greetings, :place_id, where: 'NOT deleted', name: 'index_greetings_place_id_not_deleted'
    add_index :greetings, [ :start_at, :end_at ], where: 'deleted', name: 'index_greetings_time_deleted'
    add_index :greetings, [ :start_at, :end_at ], where: 'NOT deleted', name: 'index_greetings_time_not_deleted'
    add_index :greetings, [ :start_at, :end_at, :place_id, :schedule_id, :deleted ], unique: true, name: 'index_greetings_uniqueness'
    add_index :greetings, :id, where: 'NOT deleted'
    add_index :greetings, :schedule_id, where: 'NOT deleted'

    create_table :characters do |t|
      t.string :name, null: false, unique: true
    end
    add_index :characters, :name

    create_table :costumes do |t|
      t.string :name, null: false, unique: true
    end
    add_index :costumes, :name

    create_table :places do |t|
      t.string :name, null: false, unique: true
    end

    create_table :appearances do |t|
      t.integer :greeting_id, null: false
      t.integer :character_id, null: false
      t.integer :costume_id
      t.string  :raw_character_name, null: false
    end
    add_index :appearances, :greeting_id
    add_index :appearances, :character_id
    add_index :appearances, [ :greeting_id, :character_id, :costume_id ], unique: true, name: 'index_appearances_uniqueness'
    add_index :appearances, [ :character_id, :costume_id ]

    create_table :schedules do |t|
      t.date :date, null: false, unique: true
    end
    add_index :schedules, :date
  end
end
