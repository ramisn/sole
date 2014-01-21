# This module can be included in models that need to access the current thread's request information
module ModelRequestInfo
  
  def set_request_for_models
    ModelRequestInfo.request = request
    ModelRequestInfo.flash = flash
    ModelRequestInfo.current_user = current_user
  end

  module ModelMethods
    def request
      Thread.current[:request]
    end
    
    def flash
      Thread.current[:flash]
    end
    
    def current_user
      Thread.current[:current_user]
    end
  end
  
  def self.request=(req)
    Thread.current[:request] = req
  end
  
  def self.flash=(flash)
    Thread.current[:flash] = flash
  end
  
  def self.current_user=(user)
    Thread.current[:current_user] = user
  end
end
