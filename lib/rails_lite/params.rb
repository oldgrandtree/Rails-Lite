require 'uri'

class Params
  # use your initialize to merge params from
  # 1. query string
  # 2. post body
  # 3. route params
  def initialize(req, route_params = {})
    @req = req
    @params = route_params
      .merge(parse_www_encoded_form(@req.query_string.to_s))
      .merge(parse_www_encoded_form(@req.body.to_s))
  end

  def [](key)
    @params[key]
  end

  def permit(*keys)
  end

  def require(key)
  end

  def permitted?(key)
  end

  def to_s
    @params.to_s
  end

  class AttributeNotFoundError < ArgumentError; end;

  private
  # this should return deeply nested hash
  # argument format
  # user[address][street]=main&user[address][zip]=89436
  # should return
  # { "user" => { "address" => { "street" => "main", "zip" => "89436" } } }
  def parse_www_encoded_form(www_encoded_form)
    query_params = {}

    www_encoded_form.split("&").each do |query_str|
      query_params.merge!(de_nest(query_str))
    end

    query_params
  end

  def de_nest(query_str)
    if query_str.include?("[")
      key = /\w+/.match(query_str).to_s
      {key => de_nest(/\[(.+)/.match(query_str)[1])}
    else
      {/\w+/.match(query_str).to_s => /=(\w+)/.match(query_str)[1]}
    end
  end

  # this should return an array
  # user[address][street] should return ['user', 'address', 'street']
  def parse_key(key)
  end
end
