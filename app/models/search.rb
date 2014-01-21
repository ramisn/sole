# Search class handles search on members, and stores. See search_controller
# for example usage.
#--
# Technically, the purpose of this class is to hide implementation details
# from controllers, and provide a single interface, avoiding duplication of
# the code between controllers.
#
# In the next phase, the product search should be integrated to the class,
# and {Search,User}#search methods should rely on index search, such as
# IndexTank, or similar.
#++
class Search

  # The attribute defines the suffix of search methods for a kind. 
  @@search_suffix = '_results'
  cattr_reader :search_suffix

  %w{kind taxon q}.each do |a|
    attr_accessor a.to_sym
  end

  def initialize(kind, q=nil)
    self.kind, self.q = (kind ? kind.to_sym : nil), q
  end
  
  # Perform the search on the kind.
  def results
    meth = [kind.to_s, self.search_suffix].join.to_sym
    return([]) unless respond_to?(meth) # Ensure no hijackers.
    return([]) if q.nil?
  
    send(meth)
  end

  #--
  # Perform the search on products.
  # def product_results; end
  #++
  
  # Perform the search on members.
  def member_results
    Spree::User.latest.includes(:profile_image, :user_authentications).search!(q)
  end

  # Perform the search on stores.
  def store_results
    Store.latest.includes(:profile_image).search!(q)
  end
end