require 'erb'
require 'active_support/inflector'
require_relative 'params'
require_relative 'session'


class ControllerBase
  attr_reader :params, :req, :res

  # setup the controller
  def initialize(req, res, route_params = {})
    @req, @res = req, res
    @session = Session.new(@req)
    @params = Params.new(@req, route_params)

    #needed?
    @session.store_session(@res)
  end

  # populate the response with content
  # set the responses content type to the given type
  # later raise an error if the developer tries to double render
  def render_content(content, type)
    raise "Double render error" if already_built_response?
    @res.body = content
    @res.content_type = type
    @already_built_response = true
  end

  # helper method to alias @already_built_response
  def already_built_response?
    @already_built_response
  end

  # set the response status code and header
  def redirect_to(url)
    raise "Double render error" if already_built_response?
    @res["location"] = url
    @res.status = 302
    @already_built_response = true
    @session.store_session(@res)
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    raise "Double render error" if already_built_response?

    @session.store_session(@res)

    @res.body = ERB.new(File.read(path(template_name))).result(binding)
    @res.content_type = "text/html"
    @already_built_response = true
  end

  def path(template_name)
    "views/#{self.class.name.underscore}/#{template_name}.html.erb"
  end

  # method exposing a `Session` object
  def session
    @session
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
  end
end
