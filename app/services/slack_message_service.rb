class SlackMessageService
  def initialize(message:, emoji: ':soccer:')
    @message = message
    @emoji = emoji
  end

  def notify
    post_message_to_slack
  end

  private

  def slack_message_params
    {
      text: @message,
      icon_emoji: @emoji,
      username: 'WC Bot'
    }
  end

  def http_request(url)
    uri = URI.parse(url)
    @http = Net::HTTP.new(uri.host, uri.port)
    @http.use_ssl = true
    Net::HTTP::Post.new(uri.request_uri)
  end

  def post_message_to_slack
    slack_url = ENV.fetch('SLACK_URL', nil)
    return unless slack_url

    params = slack_message_params
    request = http_request(slack_url)
    request.body = params.to_json
    @http.request(request)
  end
end
