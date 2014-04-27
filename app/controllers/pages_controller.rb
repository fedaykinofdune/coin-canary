class PagesController < ApplicationController
  def home
    @coin = Rails.cache.fetch("multipool:coin:current", expires_in: 5.minutes) do
      Multipool::Coin.current
    end
  end
end
