FactoryGirl.define do
  factory :vendor_payment do
    order nil
    amount 100.00
    state 'settled'
    vendor_payment_period { FactoryGirl.create(:vendor_payment_period, :payment_total => 100.00, :total => 100.00) }
    admin_id { FactoryGirl.create(:admin_user).id }
    
    trait :ready do
      state 'ready'
      amount 0.00
    end
    
    factory :ready_vendor_payment, :traits => [:ready]
  end
end
