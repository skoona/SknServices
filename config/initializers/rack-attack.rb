# In config/initializers/rack-attack.rb

class Rack::Attack

  ### Configure Cache ###
  # Note: The store is only used for throttling (not blacklisting and
  # whitelisting). It must implement .increment and .write like
  # ActiveSupport::Cache::Store

  # Ref: http://guides.rubyonrails.org/caching_with_rails.html#activesupport-cache-store
  Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new

  # Throttle all requests by IP (60rpm)
  #
  # Key: "rack::attack:#{Time.now.to_i/:period}:req/ip:#{req.ip}"
  throttle('req/ip', :limit => 300, :period => 5.minutes) do |req|
    req.ip unless req.path.start_with?('/assets')
  end

  ### Prevent Brute-Force Login Attacks ###

  # Throttle POST requests to /sessions by IP address
  # /signin is a :get
  # Key: "rack::attack:#{Time.now.to_i/:period}:logins/ip:#{req.ip}"   7/20 was good
  throttle('sessions/ip', :limit => 8, :period => 20.seconds) do |req|
    if req.path == '/sessions' && req.post?
      req.ip
    end
  end

  ### Custom Throttle Response ###

  # While Rack::Attack's primary focus is minimizing harm from abusive clients, it can
  # also be used to return rate limit data that's helpful for well-behaved clients.
  Rack::Attack.throttled_response = lambda do |env|
    now = Time.now
    match_data = env['rack.attack.match_data']

    headers = {
        'X-RateLimit-Limit' => match_data[:limit].to_s,
        'X-RateLimit-Remaining' => '0',
        'X-RateLimit-Reset' => (now + (match_data[:period] - now.to_i % match_data[:period])).to_s
    }

    [ 429, headers, ["Too many requests. Please try again later.\n"]]
  end

end
