require 'active_support'
require 'active_support/inflector'
require 'active_support/core_ext'
require 'erb'
require_relative './session'

class ControllerBase
  attr_reader :req, :res, :params
  attr_accessor :already_built_response

  # Setup the controller
  def initialize(req, res)
    @req, @res = req, res
    @already_built_response = false
  end

  # Helper method to alias @already_built_response
  def already_built_response?
    @already_built_response
  end

  # Set the response status code and header
  def redirect_to(url)
    raise "Cannot double render" if already_built_response?    
    @res.header['location'] = url
    @res.status = 302
    @already_built_response = true
  end

  # Populate the response with content.
  # Set the response's content type to the given type.
  # Raise an error if the developer tries to double render.
  def render_content(content, content_type)
    raise "Cannot double render" if already_built_response?
    @res.write(content)
    @res['Content-Type'] = content_type
    @already_built_response = true
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    dirctry_path = File.dirname(__FILE__)
    template_filename = File.join(
      dirctry_path, "..",
      "views", self.class.name.underscore, "#{template_name}.html.erb"
    )

    coded_template = File.read(template_filename)

    render_content(
      ERB.new(coded_template).result(binding), "text/html"
    )
  end

  # method exposing a `Session` object
  def session
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
  end
end

