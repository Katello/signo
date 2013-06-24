# Small helper class to work with urls in a way we need
class Url
  def initialize(url)
    @url = parse(url)
  end

  # converts url to https scheme if enforced by configuration
  #
  # if a RP uses rack <= 1.2 it does not detect url scheme correctly when it's behind proxy
  # so we'd redirect back to https app with http request
  # because of that we must ensure we use https if it's turned on in configuration
  def sslize
    @url.scheme = 'https' if ::Configuration.config.enforce_ssl
    self
  end

  # adds username parameter to a url
  def add_username(username)
    param = "username=#{URI.escape(username)}"
    @url.query.present? ? @url.query += "&#{param}" : @url.query = param
    self
  end

  # returns complete url as a string
  def to_s
    @url.to_s
  end

  private

  # we need some fixes for wrongly escaped urls
  def parse(url)
    URI.parse(url.gsub(' ', '%20'))
  end

end
