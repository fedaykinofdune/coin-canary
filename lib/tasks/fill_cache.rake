task 'multipool:cache:fill' => :environment do
  Rails.cache.write(Multipool::API::GET_CACHE_KEY, expires_in: 1.hour) do
    Multipool::API.get
  end
end
