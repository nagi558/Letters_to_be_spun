module Api
  module V1
    class CategoryPostsController < ApplicationController
      before_action :authenticate_user!

      def index
        category = current_user.categories.find(params[:category_id])
        posts = category.posts.order(created_at: :desc)
        render json: {
          category: { id: category.id, name: category.name },
          posts: posts.as_json(only: %i[id title body created_at updated_at])
        }, status: :ok
      end
    end
  end
end
