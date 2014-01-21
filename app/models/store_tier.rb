class StoreTier < ActiveRecord::Base
  has_many :stores
  validates :name, :presence => true, :uniqueness => true
  validates :discount, :presence => true, :allow_nil => true
end
