class ArticlesController < ApplicationController
  before_filter :require_login

  def index
    @articles = Article.order("published_at desc")
  end

  def show
    @article = Article.find(params[:id])
  end

  def rb
    response_hash = oauth_access_token.get('/single_sign_on').parsed

    redirect_to root_url, notice: response_hash['message'] and return unless response_hash['status']

    redirect_to response_hash['url']
  end
end
