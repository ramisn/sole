module Soletron
  module Searcher
    extend ActiveSupport::Concern

    included do
      alias :spree_get_products_conditions_for :get_products_conditions_for
      alias :spree_retrieve_products :retrieve_products
    
      @@like_columns = [
        'products.name', 'products.meta_keywords',
        'brands.name', 'product_properties.value', 'taxons.name'
      ].freeze
      cattr_reader :like_columns
    
      @@exact_columns = [
        'option_types.name'
      ].freeze
      cattr_reader :exact_columns
    
      @@includes = [
        :brand,
        :images,
        :master,
        :color1_option_types,
        :product_properties,
        :taxons
      ].freeze
      cattr_reader :includes
    
      def get_products_conditions_for(base_scope, query)
        custom_get_products_conditions_for(base_scope, query)
      end
    
      # def retrieve_products
      #    custom_retrieve_products
      #  end
    end

    module InstanceMethods
      def custom_get_products_conditions_for(base_scope, query)
        conditions, params = [], []
        words = query.split(/[ \t\n\r]/)

        self.like_columns.each do |col|
          words.each do |q|
            conditions << "LOWER(#{col}) LIKE ?"
            params << "%#{q.strip.downcase}%"
          end
        end
      
        self.exact_columns.each do |col|
          words.each do |q|
            conditions << "LOWER(#{col}) = ?"
            params << q.strip.downcase
          end
        end
      
        base_scope = base_scope.includes(*includes)
        base_scope.where(conditions.join(" OR "), *params).order("rating DESC")
      end 
    
      # def custom_retrieve_products
      #         base_scope = get_base_scope
      #         puts base_scope
      #         @products_scope = @product_group.apply_on(base_scope)
      #         puts @products_scope
      #         @products = @products_scope.includes([:images, :master])
      #         
      #       end
    end
  end
end

Spree::Core::Search::Base.send(:include, Soletron::Searcher)