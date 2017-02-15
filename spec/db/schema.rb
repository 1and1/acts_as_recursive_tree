# encoding: UTF-8

ActiveRecord::Schema.define(:version => 0) do

  create_table :nodes do |t|
    t.integer :parent_id
    t.string :name
    t.boolean :active, default: true
  end

  add_foreign_key(:nodes, :nodes, column: :parent_id)

  create_table :node_infos do |t|
    t.belongs_to :node
    t.string :status
  end

  create_table :node_with_other_parent_keys do |t|
    t.integer :other_id
  end

  create_table :locations do |t|
    t.integer :parent_id
    t.string :name
    t.string :type
  end

  add_foreign_key(:locations, :locations, column: :parent_id)
end