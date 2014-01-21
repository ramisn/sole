class AbilityDecorator
  include CanCan::Ability

  def initialize(user)
    user ||= Spree::User.new

    can :manage, :all if user.admin?
    
    if user.merchant?
      # controllers have a before filter checking if the object belongs to user
      
      can :index, Store
      can :manage, Spree::Image
      can :manage, Spree::Product
      can :manage, Spree::Order
      can :manage, Store
      can :manage, Spree::Variant
	    can :manage, BannerImage
	    can :manage, ProfileImage
      can :manage, Spree::InventoryUnit
      can :manage, OrdersStore
      can :manage, [ VendorPaymentPeriod, 
                   VendorPayment ]

      can :manage, [ Merchant::ImagesController,
                     Merchant::OrdersController,
                     Merchant::ProductsController,
                     Merchant::StoreAdminController,
                     Merchant::StoreController,
					           Merchant::StoreSettingsController,
					           Merchant::BannerImagesController,
					           Merchant::ImagesController,
					           Merchant::ProfileImagesController,
                     Merchant::VariantsController, 
                     Merchant::InventoryUnitsController ]
      can :manage, [ Merchant::VendorPaymentPeriodsController,
                   Merchant::VendorPaymentsController ]
    end

    can :edit_profile, Spree::User do |resource|
      resource == user
    end
    can :update_profile, Spree::User do |resource|
      resource == user
    end
    can :authentications, Spree::User do |resource|
      resource == user
    end

    can :create, ProfileImage do |resource|
      resource.viewable == user
    end
    can :read, ProfileImage do |resource|
      resource.viewable == user
    end
    can :update, ProfileImage do |resource|
      resource.viewable == user || (resource.viewable.class == Spree::Taxon && Spree::Taxon.find(resource.viewable.id))
    end

    can :create, BannerImage do |resource|
      resource.viewable.class == Spree::Taxon && Spree::Taxon.find(resource.viewable.id)
    end
    can :read, BannerImage
    can :update, BannerImage do |resource|
      resource.viewable.class == Spree::Taxon && Spree::Taxon.find(resource.viewable.id)
    end

    can :create, Follow do |resource|
      user
    end
    can :destroy, Follow do |resource|
      resource.follower == user || (resource.follower.is_a?(Spree::Taxon) && Spree::Taxon.find(resource.following_id))
    end
  end
end

Spree::Ability.register_ability(AbilityDecorator)
