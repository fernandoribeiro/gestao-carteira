#encoding: UTF-8

class MainController < ApplicationController

  def index
  end


  private
  
	  def load_title_end_subtitle
	    @title = "Gestão de Carteira"
	    @subtitle = "Bem Vindo"
	  end

end
