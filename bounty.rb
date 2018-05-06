class Bounty < ActiveRecord::Base
	belongs_to :product 
	has_many :comment, as: :commentable, dependent: :destroy
	att_accessible :product, :comments, :question, :response_count, :product_id
	
	def top_responses
		return self.comments.order('rating DESC')
	end
end