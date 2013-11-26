require 'spree_core'
require 'spree_reviews_hooks'

module SpreeReviews
  class Engine < Rails::Engine

    config.autoload_paths += %W(#{config.root}/lib)

    def self.activate
      Dir.glob(File.join(File.dirname(__FILE__), "../app/**/*_decorator*.rb")) do |c|
        Rails.env.production? ? require(c) : load(c)
      end

      # make your helper avaliable in all views
      Spree::BaseController.class_eval do
        helper ReviewsHelper
      end
      ProductsController.class_eval do
        helper ReviewsHelper
      end

    end

    config.to_prepare &method(:activate).to_proc
  end
end
