module ActsAsRecursiveTree
  module Builder
    module RecursionDirection
      class Ancestor
        def build(base_table, loc_table, config)
          loc_table[config.parent_key].eq(base_table[config.primary_key])
        end
      end
      class Descendant
        def build(base_table, loc_table, config)
          base_table[config.parent_key].eq(loc_table[config.primary_key])
        end
      end

      def self.for(direction)
        "#{self.name}::#{direction.to_s.classify}".constantize.new
      end
    end
  end
end
