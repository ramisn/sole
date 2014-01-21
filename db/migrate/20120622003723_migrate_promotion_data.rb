class MigratePromotionData < ActiveRecord::Migration
  include ActiveRecord::ConnectionAdapters::Quoting
  
  def up
    ###
    # Need to make it so that promotions from the promotions table are sent to the activators table, which is
    # basically the same.  Then need to make sure that preferences, rules, and actions for the promotions are
    # saved against those in the activator table
    ###
    records = ActiveRecord::Base.connection.raw_connection.query(%{SELECT * FROM promotions}, symbolize_keys: true, as: :hash)
    records.each do |promotion|
      promotion_clone = promotion.clone
      promotion_clone.delete :id
      promotion_clone.delete :combine
      # Create activator-based promotion
      activator = Spree::Promotion.create(promotion_clone)
      
      # Update PromotionRules
      Spree::PromotionRule.update_all({:activator_id => activator.id}, {:activator_id => promotion[:id]})
      
      # Add Actions
      action = Spree::Promotion::Actions::CreateAdjustment.create(:promotion => activator)
      Spree::Calculator.update_all({:calculable_type => "Spree::Promotion::Actions::CreateAdjustment", :calculable_id => action.id}, 
                                   {:calculable_type => "Promotion", :calculable_id => promotion[:id]})
      
      # Update Adjustments
      Spree::Adjustment.update_all({source_id: activator.id, originator_type: "Spree::Promotion::Actions::CreateAdjustment", originator_id: action.id}, 
                                   {source_id: promotion[:id], source_type: "Spree::Promotion"})
    end
  end

  def down
    #create_table :promotions, :force => true do |t|
    #  t.string   :name
    #  t.string   :code
    #  t.string   :description
    #  t.integer  :usage_limit
    #  t.boolean  :combine
    #  t.datetime :expires_at
    #  t.datetime :starts_at
    #  t.string   :match_policy, :default => 'all'
    #
    #  t.timestamps
    #end
  end
end
