# encoding: UTF-8

ActiveRecord::Schema.define(:version => 0) do

  create_table :nodes do |t|
    t.integer :parent_id
    t.string :name
  end

  add_foreign_key(:nodes, :nodes, column: :parent_id)

  create_table :locations do |t|
    t.integer :parent_id
    t.string :name
    t.string :type
  end

  add_foreign_key(:locations, :locations, column: :parent_id)
end