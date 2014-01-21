Spree::Image.class_eval do
  
  validates_attachment_presence :attachment
  
  has_attached_file :attachment, 
    :styles => { 
     :mini => '46x46#', # thumbs under image
     :small => '152x152#', # images on category view
     :product => '160x160#', # full product image
     :market => '235x235#', # the new market image wanted
     :large_square => "480x480#",
     :large => '480x8000>' # light box image
    },
    :default_style => :product,
    :path => "assets/products/:id/:style/:basename.:extension",
    :storage => 's3',
    :s3_credentials => {
         :access_key_id => S3_CONFIG["access_key_id"] ,
         :secret_access_key => S3_CONFIG["secret_access_key"]
       },
    :bucket => S3_CONFIG["bucket"]

end
