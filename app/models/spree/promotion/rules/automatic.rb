# A rule that flags this promotion as being automatically given to orders
class Spree::Promotion::Rules::Automatic < Spree::PromotionRule
  def eligible?(order)
    true
  end
end