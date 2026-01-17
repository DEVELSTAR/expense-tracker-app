# frozen_string_literal: true

# Rate limiting configuration using Rack::Attack
# Protects against brute force attacks and abuse

class Rack::Attack
  # Use Rails cache for storing rate limit data
  Rack::Attack.cache.store = Rails.cache

  ### Throttle Configurations ###

  # Throttle login attempts by IP address (5 requests per 20 seconds)
  throttle("logins/ip", limit: 5, period: 20.seconds) do |req|
    if req.path == "/users/sign_in" && req.post?
      req.ip
    end
  end

  # Throttle login attempts by email address (5 requests per 20 seconds)
  throttle("logins/email", limit: 5, period: 20.seconds) do |req|
    if req.path == "/users/sign_in" && req.post?
      # Normalize email: downcase and strip whitespace
      req.params.dig("user", "email")&.to_s&.downcase&.strip.presence
    end
  end

  # Throttle password reset requests by IP (5 requests per 20 seconds)
  throttle("password_reset/ip", limit: 5, period: 20.seconds) do |req|
    if req.path == "/users/password" && req.post?
      req.ip
    end
  end

  # Throttle password reset requests by email (5 requests per hour)
  throttle("password_reset/email", limit: 5, period: 1.hour) do |req|
    if req.path == "/users/password" && req.post?
      req.params.dig("user", "email")&.to_s&.downcase&.strip.presence
    end
  end

  # Throttle registration attempts (10 per hour per IP)
  throttle("registrations/ip", limit: 10, period: 1.hour) do |req|
    if req.path == "/users" && req.post?
      req.ip
    end
  end

  # General rate limit: 300 requests per 5 minutes per IP
  throttle("requests/ip", limit: 300, period: 5.minutes) do |req|
    req.ip unless req.path.start_with?("/assets")
  end

  ### Custom Responses ###

  # Return a custom response when throttled
  self.throttled_responder = lambda do |request|
    match_data = request.env["rack.attack.match_data"]
    now = match_data[:epoch_time]
    retry_after = (match_data[:period] - now % match_data[:period]).to_i

    [
      429,
      {
        "Content-Type" => "text/html",
        "Retry-After" => retry_after.to_s
      },
      [ <<~HTML
        <!DOCTYPE html>
        <html>
        <head>
          <title>Too Many Requests</title>
          <meta name="viewport" content="width=device-width,initial-scale=1">
          <style>
            body {#{' '}
              font-family: system-ui, -apple-system, sans-serif;#{' '}
              background: #0f0f1a;#{' '}
              color: #ffffff;#{' '}
              display: flex;#{' '}
              min-height: 100vh;#{' '}
              align-items: center;#{' '}
              justify-content: center;#{' '}
              margin: 0;
            }
            .container {#{' '}
              text-align: center;#{' '}
              max-width: 500px;#{' '}
              padding: 2rem;
            }
            h1 {#{' '}
              color: #f87171;#{' '}
              margin-bottom: 1rem;
              font-size: 2rem;
            }
            p {#{' '}
              color: #9ca3af;#{' '}
              line-height: 1.6;
            }
            .retry {#{' '}
              margin-top: 1rem;#{' '}
              padding: 0.5rem 1rem;
              background: #1e1e2e;
              border-radius: 8px;
              display: inline-block;
            }
          </style>
        </head>
        <body>
          <div class="container">
            <h1>⏳ Too Many Requests</h1>
            <p>You've made too many requests in a short period. Please wait a moment before trying again.</p>
            <div class="retry">Retry after #{retry_after} seconds</div>
          </div>
        </body>
        </html>
      HTML
      ]
    ]
  end

  ### Safelist Configurations ###

  # Always allow requests from localhost in development
  safelist("allow-localhost") do |req|
    Rails.env.development? && [ "127.0.0.1", "::1" ].include?(req.ip)
  end
end
