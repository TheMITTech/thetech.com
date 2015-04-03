module Techplater
  class Renderer
    include ExternalFrontendUrlHelper

    def initialize(template, chunks)
      @template = template
      @chunks = chunks
    end

    def render
      require 'handlebars'

      handlebars = Handlebars::Context.new
      handlebars.register_helper(:imageTag, &method(:image_tag_helper))
      handlebars.register_helper(:articleListTag, &method(:article_list_tag_helper))

      template = handlebars.compile(@template)

      template.call(chunks: @chunks)
    end

    private
      def image_tag_helper(context, image, style)
        begin
          picture = Picture.find(image)
          image = picture.image

          attribution = "<span class='attribution'>#{image.attribution}</span>"

          if image.author
            attribution = "<a href='#{external_frontend_photographer_url image.author}'>#{attribution}</a>"
          end

          [
            "<figure class='article-img #{style}'>",
            "  <a href='#{picture.content.url(:large)}' data-lightbox='images' data-title='#{ERB::Util.html_escape(image.caption)} #{ERB::Util.html_escape(image.attribution.upcase)}' class='lightbox-link'>",
            "    <img src='#{picture.content.url(:large)}'>",
            "  </a>",
            "  <figcaption>#{image.caption}",
            attribution,
            "  </figcaption>",
            "</figure>",
          ].join("\n")
        rescue ActiveRecord::RecordNotFound
          ''
        end
      end

      def article_list_tag_helper(context, article_list)
        begin
          [
            "<ol class='article_list'>",
            ArticleList.find(article_list).article_list_items.map do |i|
              "<li>" + "<a href='#{i.piece.frontend_display_path}'>#{i.piece.title}</a>" + "</li>"
            end,
            "</ol>"
          ].join("\n")
        rescue ActiveRecord::RecordNotFound
          ''
        end
      end
  end
end