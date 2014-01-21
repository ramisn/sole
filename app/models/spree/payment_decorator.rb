Spree::Payment.class_eval do
  
  scope :refunds, where('payments.amount < 0')
  # fix bug when reattempting gateway error - :started_processing must be able to start from :failed
  # order state machine (see http://github.com/pluginaweek/state_machine/tree/master for details)
  state_machine :initial => 'checkout' do
    # With card payments, happens before purchase or authorization happens
    event :started_processing do
      transition :from => ['checkout', 'pending', 'completed', 'failed'], :to => 'processing'
    end
    # When processing during checkout fails
    event :fail do
      transition :from => 'processing', :to => 'failed'
    end
    # With card payments this represents authorizing the payment
    event :pend do
      transition :from => 'processing', :to => 'pending'
    end
    # With card payments this represents completing a purchase or capture transaction
    event :complete do
      transition :from => ['processing', 'pending'], :to => 'completed'
    end
    event :void do
      transition :from => ['pending', 'completed'], :to => 'void'
    end
  end

end