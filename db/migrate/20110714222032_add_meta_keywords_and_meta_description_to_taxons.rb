class AddMetaKeywordsAndMetaDescriptionToTaxons < ActiveRecord::Migration
  def self.up
    change_table :taxons do |t|
      t.string :meta_keywords
      t.string :meta_description
    end
  end

  def self.down
    change_table :taxons do |t|
      t.remove :meta_keywords
      t.remove :meta_description
    end
  end
end
