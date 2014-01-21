class Brand < ActiveRecord::Base

  has_many :products, :class_name => "Spree::Product"
  has_and_belongs_to_many :stores

  scope :alphabetically, order(:name)
end
