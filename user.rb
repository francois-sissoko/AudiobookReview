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
	
	def swagger
		bards_rating + like_rating
	end
	
	def creator_heat
		rating = 0
		self.products.each do |p|
			rating += p.rating 
		end
		rating
	end
	
	def lovers 
		luvrs = 0
		self.products.each do |p| 
			luvrs += p.likes.length
		end
		return luvrs
	end
	
#Section for adding Profile Pictures
	
	def profile_pic
		if self.propic_id
			ImageAsset.find(self.propic_id)
		elseif !self.pictures.empty?
			self.pictures.last
		else 
			nil
		end
	end
	
	def profile_pic_url(size=:large)
		p self.profile_pic
		case self.profile_pic
		when nil
			'/images/missing-user-avatar.png'
		else
			self.profile_pic.attachment.url(size)
		end
	end
	
	def has_pics?
		return !self.pictures.empty?
	end
	
	def first_name
		self.name.split(' ')[0]
	end
	
	#Send email to user of confirmation of regestration
	def self.test_reg_email(user)
		NewUser.registration_confirmation(user).deliver
	end
	
	def send_password_reset
		generate_token(:password_reset_token)
		self.password_reset_sent_at = Time.zone.now
		save!
		UserMailer.password_reset(self).deliver
	end
	
	private
	
	def create_remember_token
		self.remember_token = User.encrypt(User.new_remember_token)
	end
	
	def save_pictures
		self.pictures.each do |asset|
			asset.user_id = self.id
			asset.save!
		end
	end
	
	

	

	
