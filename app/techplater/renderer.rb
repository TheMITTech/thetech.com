module Techplater
  class Renderer
    def initialize(template, chunks)
      @template = template
      @chunks = chunks
    end

    def render
      require 'handlebars'

      handlebars = Handlebars::Context.new
      handlebars.register_helper(:imageTag) do |context, image, style|
        begin
          [
            "<figure class='article-img #{style}'>",
            "  <img src='#{Image.find(image).content.url}'>",
            "  <figcaption>#{Image.find(image).caption}",
            "    <span>#{Image.find(image).attribution}</span>",
            "  </figcaption>",
            "</figure>"
          ].join("\n")
        rescue ActiveRecord::RecordNotFound
          ''
        end
      end

      template = handlebars.compile(@template)

      template.call(chunks: @chunks)
    end
  end
end