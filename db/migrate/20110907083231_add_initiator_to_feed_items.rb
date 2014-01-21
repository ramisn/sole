class AddInitiatorToFeedItems < ActiveRecord::Migration
  def self.up
    change_table :feed_items do |t|
      t.references :initiator, :polymorphic => true
    end
    
    FeedItem.all.each do |feed_item|
      if feed_item
        initiator = case feed_item.feedable
        when Shoutout
          feed_item.feedable.poster
        when Follow
          feed_item.feedable.follower
        when Favorite, Order
          feed_item.feedable.user
        when Product
          if feed_item.feedable.store_taxon
            feed_item.feedable.store_taxon.store
          end
        when Comment
          feed_item.feedable.commenter
        else
          #puts " didn't find '#{feed_item.feedable.class.name}"
        end
        #puts "#{feed_item.feedable.class} #{initiator}"
        if initiator
          feed_item.update_attributes(:initiator_type => initiator.class.name, :initiator_id => initiator.id)
        end
      end
    end
    
    add_index :feed_items, [:feedable_type, :feedable_id]
    add_index :feed_items, [:displayable_type, :displayable_id]
    add_index :feed_items, [:initiator_type, :initiator_id]
  end

  def self.down
    drop_index :feed_items, [:initiator_type, :initiator_id]
    change_table :feed_items do |t|
      t.remove :initiator_type
      t.remove :initiator_id
    end
    drop_index :feed_items, [:feedable_type, :feedable_id]
    drop_index :feed_items, [:displayable_type, :displayable_id]
  end
end
