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
            "  <img src='#{Picture.find(image).content.url(:large)}'>",
            "  <figcaption>#{Picture.find(image).image.caption}",
            "    <span>#{Picture.find(image).image.attribution}</span>",
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