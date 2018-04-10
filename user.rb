 User < ActiveRecord::Base
	before_save { self.email = email.downcase }
	before_create :create_remember_token
	has_many :products, depenent: :destory
	has_many :comments, depenent: :destory
	has_many :likes, depenent: :destory
	has_many :activities, dependent: :destory

	validates: name, presence: true
	validates_confirmation_of :password
	validates_presence_of :password
	validates_presence_of :password, on: :create
	validates_presence_of :email
	validates_format_of :email, with => /\A([^@\s]+@((?: [-a-z0-9]+\.) + [a-z]{2, })\z/i
						attr_accessible :id, :name, :screen_name, :email, :bio, :creator, :creator_code, :password_confirmation, :image_asset, :remember_token, link, :user_id, :product_id, :pictures, :attachment, :attachment_attributes, :pictures_attributes, :profile_picture, :profile_picture_attibutes 
	has_secure_password
	has_many :pictures, class_name: "ImageAsset", foreign_key: "attachable_id", as: :attachable, autosave: true

	after_update :save_pictures
	before_create { generate_token(:remember_token)  }

	def generate_token(column)
		begin
		  self[column] = SecureRandom.urlsafe_base64
		end while User.exists?(column => self[column])
	end
	
	def User.new_remember_token
		SecureRandom.urlsafe_base64
	end

	#Encrypting the remembered information 
	
	def User.encrypt(token)
		Digest::SHA1.hexdigest(token.to_s)
	end
	

	
