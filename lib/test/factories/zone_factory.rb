FactoryGirl.define do
  factory :global_zone, :class => Spree::Zone do
    name 'GlobalZone'
    description { Faker::Lorem.sentence }
    zone_members do |proxy|
      zone = proxy.instance_eval{@instance}
      Spree::Country.find(:all).map{|c| Spree::ZoneMember.create({:zoneable => c, :zone => zone})}
    end

    initialize_with { Spree::Zone.find_or_initialize_by_name("GlobalZone") }
  end

  factory :zone, class: Spree::Zone do
    name { Faker::Lorem.words }
    description { Faker::Lorem.sentence }
    #zone_members do |member|
    #  [ZoneMember.create(:zoneable => FactoryGirl.create(:country) )]
    #end
    zone_members { [Spree::ZoneMember.create(:zoneable => FactoryGirl.create(:country) )] }
  end
end
