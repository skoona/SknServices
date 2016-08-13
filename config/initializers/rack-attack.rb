# In config/initializers/rack-attack.rb

class Rack::Attack

  ### Configure Cache ###

  # If you don't want to use Rails.cache (Rack::Attack's default), then
  # configure it here.
  #
  # Note: The store is only used for throttling (not blacklisting and
  # whitelisting). It must implement .increment and .write like
  # ActiveSupport::Cache::Store

  Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new

  ### Throttle Spammy Clients ###

  # If any single client IP is making tons of requests, then they're
  # probably malicious or a poorly-configured scraper. Either way, they
  # don't deserve to hog all of the app server's CPU. Cut them off!
  #
  # Note: If you're serving assets through rack, those requests may be
  # counted by rack-attack and this throttle may be activated too
  # quickly. If so, enable the condition to exclude them from tracking.

  # Throttle all requests by IP (60rpm)
  #
  # Key: "rack::attack:#{Time.now.to_i/:period}:req/ip:#{req.ip}"
  throttle('req/ip', :limit => 300, :period => 5.minutes) do |req|
    req.ip unless req.path.start_with?('/assets')
  end

  ### Prevent Brute-Force Login Attacks ###

  # The most common brute-force login attack is a brute-force password
  # attack where an attacker simply tries a large number of emails and
  # passwords to see if any credentials match.
  #
  # Another common method of attack is to use a swarm of computers with
  # different IPs to try brute-forcing a password for a specific account.

  # Throttle POST requests to /login by IP address
  # /signin
  # Key: "rack::attack:#{Time.now.to_i/:period}:logins/ip:#{req.ip}"   7/20 was good
  throttle('logins/ip', :limit => 8, :period => 20.seconds) do |req|
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
