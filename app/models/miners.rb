module Miners
  extend self

  BASE_URL = "http://api.multipool.us/api.php?api_key=#{Settings.keys.multipool_api_key}"

  def working?
    get_multipool_api["workers"].any? do |currency, workers|
      workers.any? do |worker, worker_stats|
        worker_stats["hashrate"].to_i > 0
      end
    end
  end

  def currently_mining
    max = [nil, 0]
    get_multipool_api["workers"].each do |currency, workers|
      workers.each do |worker, worker_stats|
        hashrate = worker_stats["hashrate"].to_i
        max = [currency, hashrate] if hashrate > max.last
      end
    end
    max
  end

  def get_multipool_api
    response = HTTParty.get(BASE_URL, format: :json)
    case response.code
    when 200
      response.parsed_response
    end
  end
end
