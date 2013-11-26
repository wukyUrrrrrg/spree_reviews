class ReviewsController < Spree::BaseController
  helper Spree::BaseHelper

  def index
    @product = Product.find_by_permalink params[:product_id]
    @approved_reviews = Review.approved.find_all_by_product_id(@product.id) 
  end

  def new
    @product = Product.find_by_permalink params[:product_id] 
    @review = Review.new :product => @product
    @name = (current_user and not current_user.orders.blank? and current_user.orders.last.ship_address) ? current_user.orders.last.ship_address.firstname : '' 
  end

  # save if all ok
  def create
    @product = Product.find_by_permalink params[:product_id]
    params[:review][:rating].sub!(/\s*stars/,'') unless params[:review][:rating].blank?

    @review = Review.new :product => @product
    if @review.update_attributes(params[:review]) 
      if @review.spam?
        flash[:error] = t('you_review_is_spam')
        redirect_to (product_path(@product))
      else
        flash[:notice] = t('review_successfully_submitted')
        redirect_to (product_path(@product))
      end
    else
      # flash[:notice] = 'There was a problem in the submitted review'
      render :action => "new" 
    end
  end
  def terms
  end
end
