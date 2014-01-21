module Merchant::StoreHelper
  # This requires the controller for the action to find the Facebook pages from the user
  # and set those pages returned from Facebook as the @pages variable.
  def facebook_pages_as_options(store)
    options_for_select(@pages.inject([]) do |array, page|
      array << [page['name'], page['id']]
      array
    end, store.facebook_id)
  end
  
  # expecting @facebook_auth to be set
  def store_pull_from_facebook?(store, attribute)
    # BUGBUG (aslepak/justin): need to get current store instead of [0]. taxon now unused
    manager = store.managers.find_by_user_id(current_user)
    if manager and manager.facebook_manager?
      pull_from_facebook?(@facebook_auth, attribute)
    end
  end
end
