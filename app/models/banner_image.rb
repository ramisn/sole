class BannerImage < Image
   validate :viewable, :unique => true

   has_attached_file :attachment,
      :styles => { :mini => '60x10>', :medium => '240x40>', :large => '720x120#' },
      :default_style => :large,
      :path => "/assets/banners/:id/:style/:basename.:extension",
      :storage => "s3",
      :s3_credentials => {
         :access_key_id => S3_CONFIG["access_key_id"] ,
         :secret_access_key => S3_CONFIG["secret_access_key"]
       },
      :bucket => S3_CONFIG["bucket"]
  
end
