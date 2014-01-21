class ProfileImage < Spree::Image

   validate :viewable, :unique => true

   has_attached_file :attachment,
     :styles => { :mini => '20x20#', :small => '100x100#', :list => '200x200#', :medium => '240x240>', :large => '600x600>' },
     :default_style => :large,
     :path => "/assets/profiles/:id/:style/:basename.:extension",
     :storage => "s3",
     :s3_credentials => {
         :access_key_id => S3_CONFIG["access_key_id"] ,
         :secret_access_key => S3_CONFIG["secret_access_key"]
       },
    :bucket => S3_CONFIG["bucket"]
 
end
