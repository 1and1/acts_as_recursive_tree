# encoding: UTF-8

ActiveRecord::Schema.define(:version => 0) do

  create_table :nodes do |t|
    t.integer :parent_id
    t.string :name
  end

  add_foreign_key(:nodes, :nodes, column: :parent_id)

  create_table :vehicles do |t|
    t.integer :parent_id
    t.string :name
    t.string :type
  end

  add_foreign_key(:vehicles, :vehicles, column: :parent_id)
end