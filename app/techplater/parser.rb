module Techplater
  class Parser
    attr_reader :chunks, :image_ids

    HANDLEBARS_TEMPLATE_VERBATIM = '{{{chunks.[%d]}}}'
    HANDLEBARS_TEMPLATE_ASSET_IMAGE = '{{{imageTag %d "%s"}}}'
    HANDLEBARS_TEMPLATE_ASSET_ARTICLE_LIST = '{{{articleListTag %d}}}'
    ASSET_IMAGE_SRC_REGEX = /\/images\/\d+\/pictures\/(\d+)\/direct/
    ASSET_IMAGE_STYLE_LEFT_REGEX = /float:\s*left/
    ASSET_IMAGE_STYLE_RIGHT_REGEX = /float:\s*right/
    SUBHEAD_CHUNK = '<h3>%s</h3>'

    def initialize(text)
      @text = text
    end

    def parse!
      @chunks = []
      @template = []
      @image_ids = []

      doc = Nokogiri::HTML.fragment(@text)

      doc.children.each do |p|
        process_node(p)
      end

      @chunks.compact!
    end

    # The Rails rendering context will need to provide the following:
    #
    #   chunks: an Array of chunks
    #   helper imageTag image_id style[default, left, or right]: returns the <img> tag

    def template
      @template.join("\n")
    end

    private
      def process_node(node)
        # In case of <div>s, recurse down
        if node.name.to_sym == :div
          # Process legacy subheads
          if node['class'] == 'bodysub'
            @chunks << SUBHEAD_CHUNK % node.content
            insert_tag(HANDLEBARS_TEMPLATE_VERBATIM % (@chunks.size - 1))

            return
          end

          node.children.each { |c| process_node(c) }
          return
        end

        node = strip_images(node)
        node = strip_article_lists(node)
        node = strip_verbatim_elements(node, :table)

        return if node.nil?

        case node.name.to_sym
        when :h1, :h2, :h3, :h4, :h5, :h6, :p, :blockquote, :ul, :ol
          # When text elements consist of solely images, they will become empty after the images are stripped. In that case, skip the elements to avoid unnecessary chunks.
          return if node.content.strip.empty?
          # Verbatim elements. Just create a chunk and insert as-is
          @chunks << node.to_s
          # Note that in handlebars the index starts at 1
          # CORRECTION: Guess it starts from 0 after all...
          insert_tag(HANDLEBARS_TEMPLATE_VERBATIM % (@chunks.size - 1))
        when :img
          process_image(node)
        end
      end

      def strip_verbatim_elements(node, el)
        return nil if node.nil?

        if node.name.to_sym == el
          process_verbatim_element(node)
          return nil
        end

        node.css(el.to_s).each do |c|
          process_verbatim_element(c)
          c.remove
        end

        node
      end

      def process_verbatim_element(el)
        @chunks << el.to_s
        insert_tag(HANDLEBARS_TEMPLATE_VERBATIM % (@chunks.size - 1))
      end

      # Strip the <img> tags out of the node. Inserts template tags for each image removed.
      def strip_images(node)
        node.css('img').each do |img|
          process_image(img)
          img.remove
        end

        node
      end

      def process_image(img)
        match = ASSET_IMAGE_SRC_REGEX.match(img['src'])
        return unless match

        match_left = ASSET_IMAGE_STYLE_LEFT_REGEX.match(img['style'])
        match_right = ASSET_IMAGE_STYLE_RIGHT_REGEX.match(img['style'])

        style = 'default'
        style = 'left' if match_left
        style = 'right' if match_right

        id = match[1].to_i

        insert_tag(HANDLEBARS_TEMPLATE_ASSET_IMAGE % [id, style])
        @image_ids << id
      end

      def process_article_list(list)
        article_id = list['data-article-list-id'].try(:to_i)
        return if article_id.nil?

        insert_tag(HANDLEBARS_TEMPLATE_ASSET_ARTICLE_LIST % article_id)
      end

      # Strip the <img> tags out of the node. Inserts template tags for each image removed.
      def strip_images(node)
        return nil if node.nil?

        node.css('img').each do |img|
          process_image(img)
          img.remove
        end

        node
      end

      def strip_article_lists(node)
        return nil if node.nil?

        if node['data-role'] == 'asset-article-list'
          process_article_list(node)
          return nil
        end

        node.css('[data-role="asset-article-list"]').each do |list|
          process_article_list(list)
          list.remove
        end

        node
      end

      def process_article_list(list)
        article_id = list['data-article-list-id'].try(:to_i)
        return if article_id.nil?

        insert_tag(HANDLEBARS_TEMPLATE_ASSET_ARTICLE_LIST % article_id)
      end

      def insert_tag(tag)
        @template << tag
      end
  end
end
