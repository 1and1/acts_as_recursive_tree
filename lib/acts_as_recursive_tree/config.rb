# frozen_string_literal: true

module ActsAsRecursiveTree
  #
  # Stores the configuration of one Model class
  #
  class Config
    attr_reader :parent_key, :parent_type_column, :depth_column, :dependent

    def initialize(model_class:, parent_key:, parent_type_column:, depth_column: :recursive_depth, dependent: nil)
      @model_class        = model_class
      @parent_key         = parent_key
      @parent_type_column = parent_type_column
      @depth_column       = depth_column
      @dependent          = dependent
    end

    #
    # Returns the primary key for the model class.
    # @return [Symbol]
    def primary_key
      @primary_key ||= @model_class.primary_key.to_sym
    end

    #
    # Checks if SQL cycle detection can be used. This is currently supported only on PostgreSQL 14+.
    # @return [TrueClass|FalseClass]
    def cycle_detection?
      return @cycle_detection if defined?(@cycle_detection)

      @cycle_detection = @model_class.connection.adapter_name == 'PostgreSQL' &&
                         @model_class.connection.database_version >= 140_000
    end
  end
end
