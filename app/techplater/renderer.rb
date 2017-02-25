module Techplater
  class Renderer
    def initialize(template, chunks)
      @template = template
      @chunks = chunks
    end

    def render
      require 'handlebars'

      handlebars = Handlebars::Context.new
      template = handlebars.compile(@template)
      template.call(chunks: @chunks)
    end
  end
end