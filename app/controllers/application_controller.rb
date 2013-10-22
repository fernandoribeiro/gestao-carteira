class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :load_title_end_subtitle

  helper_method :current_title
  helper_method :current_subtitle


private

  def current_title
    @title
  end

  def current_subtitle
    @subtitle
  end

  def load_title_end_subtitle
    @title = "Title"
    @subtitle = "SubTitle"
  end
  
end
