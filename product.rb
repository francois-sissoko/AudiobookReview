class Product < ActiveRecord::Base
	belongs_to :user, foreign_key: "user_id"
  validates :name, presence: true
  validates :description, presence: true
  has_many :likes, as: :li eable, dependent: :destroy
	has_many :feature_groups, dependent: :destroy
  has_many :bounties, dependent: :destroy
  has_many :comments, as: :commentable, dependent: :destroy
	has_one :product_pic, class_name: "ImageAsset", foreign_key: "attachable_id", as: :attachable, autosave: true
  accepts_nested_attributes_for :product_pic, allow_destroy: true
	has_many :pictures, class_name: "ImageAsset", foreign_key: "attachable_id", as: :attachable, autosave: true
  accepts_nested_attributes_for :pictures, allow_destroy: true
  accepts_nested_attributes_for :feature_groups, allow_destroy: true
  accepts_nested_attributes_for :comments, allow_destroy: true
  attr_accessible :name, :description, :rating, :link, :likes, :video_url, :pictures, :active, :pictures_attributes, :product_pic, :hidden, :password, :access_list, feature_groups: [features: [:pictures]], likes: [:product_id, :user_id]
  before_create :setup_feature_bounty_content
  after_create :make_create_activity

  def liked? (id, type)
	if get_likes(id, type).length > 0
		return true
	end
	return false
  end
  
  def can_be_accessed_by(user, pwd)
	if self.hidden
		return self.password == pwd.to_s || (user and parsed_list.include?(user_id))
	end
	!self.hidden || parsed_list.include?(user.id)
  end
  
  def parsed_list
	access_list.split(",").map(&:to_i)
  end
  
  #Return a unique array of users that have liked elements of this product 
  #This is yum
  
  def followers 
	lovers = []
	self.likes.each do |l|
		lovers << l.user
	end
	self.feature_groups.each do |fg|
		fg.features.each do |f|
			f.likes.each do |l|
				lovers << l.user
			end
		end
	end
	return lovers.unique
  end 
  
  def self.top_products
	order('rating desc')
  end
  
  def top_users
  #Watch out for the swagger variable I think I changed mine
	return self.followers.sort { |x, y| x.swagger <=> y.swagger }
  end
  
  def product_pic
	if !self.product_pic.nil? and !self.product_pic.attachment.nil?
		return self.product_pic
	elsif !self.pictures.empty?
		return self.pictures.last
	else 
		return nil
	end
  end
  
  def profile_pic_url(size=:large)
	case self.profile_pic
	when nil
		'/images/missing-product.jpg'
	else
		self.product_pic.attachment.url(size)
	end
  end
  
  def rand_pic
	if !self.pictures.empty?
		return self.pictures.to_a[rand(self.pictures.size)]
	else
		return nil
	end
  end #lol Used As A sample College Code from TAIGO JUMBOS AND HAWKS
  
  def single_features
	case self.feature_groups.where(singles: true).first
	when nil
		self.feature_groups.create(singles: true)
	else 
		self.feature_groups.where(singles: true).first
	end
  end 
  
  def single
	feature_groups.where(singles: true).first
  end
  
  def comparisons
	feature_groups.where singles: false
  end
  
  def sorted_comments
	comments.order 'rating desc'
  end
  
  def top_pics
  lim = 5 
  #if there's a video, make first pic the thumbnail of video
  if self.video_url and self.video_url != ''
	lim = 4
  end 
    pics = self.pictures.where.not(attachment_file_size: nil).order('created_at DESC').limit(lim)
    pics
  end 
  
  def likers
	Product.first.likes.first(100).map(&:user)
  end
  
  def simple_link
	self.link.sub(/^https?\:\/\//, '').sub(/^www./,'').split('/')[0]
  end 
  
  #Stopped Here for the night 
  