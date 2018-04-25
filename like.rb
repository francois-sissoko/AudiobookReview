class Like < ActiveRecord::Base
	#Association for only likeable things like comparison features amd products
	belong_to :likeable, polymorphic: true
	belong_to :user
	attr_accessible :user, :user_id, :product_id, :dwmvoteable, after_create :make_life_activity
	
	#Please explain this pattern to me a little bit clearer
	def product 
		case self.likeable_type.downcase
		when 'bounty'
			self.likeable.product
		when 'features'
			self.likeable.features_group.product
		when 'product'
			self.likeable
		else
			nil
		end
	end
	
private

	def make_life_activity
		Activity.create(timestamp: Time.now, user_id, activity_type :product, resource_id: likeable_id
	end