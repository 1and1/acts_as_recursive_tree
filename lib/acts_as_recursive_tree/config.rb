# frozen_string_literal: true

module ActsAsRecursiveTree
  #
  # Stores the configuration of one Model class
  #
  class Config
    attr_reader :parent_key, :parent_type_column, :depth_column

    def initialize(model_class:, parent_key:, parent_type_column:, depth_column: :recursive_depth)
      @model_class        = model_class
      @parent_key         = parent_key
      @parent_type_column = parent_type_column
      @depth_column       = depth_column
    end

    #
    # Returns the primary key for the model class.
    # @return [Symbol]
    def primary_key
      @primary_key ||= @model_class.primary_key.to_sym
    end
  end
end
