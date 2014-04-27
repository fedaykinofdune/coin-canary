module Multipool
  module API
    extend self

    BASE_URL = "http://api.multipool.us/api.php?api_key=#{Settings.keys['MULTIPOOL_API_KEY']}"
    GET_CACHE_KEY = "multipool:api:get"

    def get
      Rails.cache.fetch(GET_CACHE_KEY, expires_in: 5.minutes) do
        response = HTTParty.get(BASE_URL, format: :json)
        case response.code
        when 200
          response.parsed_response
        end
      end
    end
  end

  module Coin
    extend self

    def current
      current_coin = { hashrate: 0 }
      API.get["workers"].each do |coin_name, workers|
        coin_hashrate = 0
        workers.each do |worker_name, stats|
          next unless worker_name.in?(Worker::ACTIVE)
          coin_hashrate += stats["hashrate"].to_i
        end
        next unless coin_hashrate > current_coin[:hashrate]
        current_coin = { name: coin_name, hashrate: coin_hashrate }
      end
      current_coin
    end
  end

  module Worker
    extend self

    ACTIVE = ['alexp.w1', 'alexp.w2']

    def all
      result = ACTIVE.inject({}) {|hash, name| hash[name] = :offline; hash}
      API.get["workers"].each do |coin_name, workers|
        workers.each do |worker_name, stats|
          next unless worker_name.in?(ACTIVE)
          result[worker_name] = :online if stats["hashrate"].to_i > 0
        end
      end
      result
    end
  end
end
