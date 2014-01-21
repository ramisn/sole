require 'spree/search/spree_sunspot/configuration'

module Spree
  module Search
    module SpreeSunspot

      class Search < defined?(Spree::Search::MultiDomain) ? Spree::Search::MultiDomain : Spree::Core::Search::Base
        def retrieve_products
          conf = Spree::Search::SpreeSunspot.configuration
          puts "retrieving products from sunspot..."
          
          return Sunspot.search(Spree::Product) do


            # conf.display_facets.each do |name|
            #   with("#{name}_facet", send(name)) if send(name)
            #   facet("#{name}_facet")
            # end

            if price     
              prices = price.split(',').map {|p| p.to_i}.sort
              
              with(:price, Range.new(prices.first, prices.last))  
              facet(:price)
            end
            
            facet(:price)

            ['size', 'color', 'department', 'brand'].each do |prop|
              with("#{prop}_facet", send(prop).split(',')) if send(prop)
              facet("#{prop}_facet")
            end

            #Taxons by name
            taxon_name.each do |taxon_name_name|
              with(:taxon_name, taxon_name_name)
            end
            with(:taxon, taxon) if taxon
            
            # if sort == 'best-selling'
            #   order_by(:sold_count, :desc)
            # else
            #   order_by sort.to_sym, order.to_sym
            # end

            case show_only
            when 'on-sale'
              with :on_sale, true
            end
            
            case sort
            when 'l2h'
              order_by :price_for_slider
            when 'h2l'
              order_by :price_for_slider, :desc
            when 'a2z'
              order_by :product_name
            when 'z2a'
              order_by :product_name, :desc
            when 'most-recent'
              order_by :available_on, :desc
            when 'most-popular'
              order_by :sold_count, :desc
            end

            with(:is_active, true)
            keywords(query)
            
            paginate(:page => page, :per_page => per)
          end

        end

        protected

        def prepare(params)
          # super copies over :taxon and other variables into properties
          # as well as handles pagination
          super
          
          @properties[:taxon]               = params[:taxon]
          @properties[:taxon_name]          = []
          @properties[:query]               = params[:keywords]
          @properties[:price]               = params[:price]
 
          @properties[:sort]                = params[:sort]
          @properties[:show_only]           = params[:show_only]
          @properties[:secondary_sort]      = params[:secondary_filter] unless params[:secondary_filter].blank?
          @properties[:order]               = params[:order] || :desc
          @properties[:department]          = params[:department]
          @properties[:color]               = params[:color].downcase if params[:color]
          @properties[:size]                = params[:size]
          @properties[:brand]               = params[:product_group_query].split("/").last unless params[:product_group_query].blank?
          @properties[:brand]               = @properties[:brands] || params[:brand]
          @properties[:per]                 = params[:per] || 50

          Spree::Search::SpreeSunspot.configuration.display_facets.each do |name|
            @properties[name] = params["#{name}_facet"] if @properties[name].blank? or !params["#{name}_facet"].blank?
          end
        end

      end

    end
  end
end
