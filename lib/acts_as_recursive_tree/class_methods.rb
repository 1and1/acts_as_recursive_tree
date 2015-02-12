module ActsAsRecursiveTree
  module ClassMethods
    extend ActiveSupport::Concern
    included do

      belongs_to :parent, class_name: name,
                 foreign_key:         self.acts_as_tree_config[:foreign_key],
                 inverse_of:          :children

      has_many :children,
               class_name:  name,
               foreign_key: self.acts_as_tree_config[:foreign_key],
               dependent:   self.acts_as_tree_config[:dependent],
               inverse_of:  :parent

      def self.root
        self.roots.first
      end

      def self.roots
        where(self.acts_as_tree_config[:foreign_key] => nil)
      end

      # def self.leaves
      #   internal_ids = select( : #{configuration[:foreign_key]}).where(arel_table[:#{configuration[:foreign_key]}].not_eq(nil))
      #     where("id NOT IN (\#{internal_ids.to_sql})")
      # end

    end
  end
end