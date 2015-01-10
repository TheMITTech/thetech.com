module Techplater
  class Renderer
    def initialize(template, chunks)
      @template = template
      @chunks = chunks
    end

    def render
      require 'handlebars'

      handlebars = Handlebars::Context.new
      handlebars.register_helper(:imagePath) do |context, image|
        Image.find(image).content.url
      end

      template = handlebars.compile(@template)

      template.call(chunks: @chunks)
    end
  end
end