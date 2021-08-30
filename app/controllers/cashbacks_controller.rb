class CashbacksController < ApplicationController
  require 'uri'
  require 'net/http'
  require 'net/https'
  require 'mime/types'
  def new
    @new_cashback = Cashback.new
  end

  def index
    @cashbacks = Cashback.where(user: current_user)
  end

  def create
    @new_cashback = Cashback.new(user: current_user)

    url = URI("https://api.mindee.net/v1/products/mindee/expense_receipts/v3/predict")
    if params[:cashback].present?
      @file = params[:cashback][:ticket]
      
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      request = Net::HTTP::Post.new(url)
      request["Authorization"] = 'Token 06cde4e0a0b3a6c856bbe7a6383021ce'
      request.set_form([['document', File.open(@file)]], 'multipart/form-data')
      
      response = http.request(request)
      @testcela = JSON.parse(response.body, symbolize_names: true)
      
      @tk_current = @testcela[:document][:inference][:prediction][:total_incl][:value]
      if @tk_current.present?
        @new_cashback.amount = (@tk_current * 5) / 100
        @new_cashback.shop = Shop.first

        if @new_cashback.save!
          sleep(0.5)
          redirect_to '/dashboard'
        else
          render :new
        end
      else
        render :new
      end
    else
      render :new
    end
  end
end
