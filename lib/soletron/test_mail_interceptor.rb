module Soletron
  class TestMailInterceptor
    class << self

      def delivering_email(mail)
        mail.to = "interceptor@soletron.com"
      end

    end
  end
end