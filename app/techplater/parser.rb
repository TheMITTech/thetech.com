module Techplater
  class Parser
    attr_reader :chunks

    HANDLEBARS_TEMPLATE_VERBATIM = '{{{chunks.[%d]}}}'
    HANDLEBARS_TEMPLATE_ASSET_IMAGE = '{{{imageTag %d "%s"}}}'
    ASSET_IMAGE_SRC_REGEX = /\/images\/\d+\/pictures\/(\d+)\/direct/
    ASSET_IMAGE_STYLE_LEFT_REGEX = /float:\s*left/
    ASSET_IMAGE_STYLE_RIGHT_REGEX = /float:\s*right/

    def initialize(text)
      @text = text
    end

    def parse!
      @chunks = []
      @template = []

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
          node.children.each { |c| process_node(c) }
          return
        end

        node = strip_images(node)
        node = strip_verbatim_elements(node, :table)

        return if node.nil?

        case node.name.to_sym
        when :h1, :h2, :h3, :h4, :h5, :h6, :p, :blockquote
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
        if node.name.to_sym == el
          process_verbatim_element(node)
          return nil
        end

        node.css(el.to_s).each do |c|
          process_verbatim_item(c)
          c.remove
        end

        node
      end

      def process_verbatim_element(el)
        @chunks << el.to_s
        insert_tag(HANDLEBARS_TEMPLATE_VERBATIM % (@chunks.size - 1))
      end

      def process_image(img)
        match = ASSET_IMAGE_SRC_REGEX.match(img['src'])
        return unless match

        match_left = ASSET_IMAGE_STYLE_LEFT_REGEX.match(img['style'])
        match_right = ASSET_IMAGE_STYLE_RIGHT_REGEX.match(img['style'])

        style = 'default'
        style = 'left' if match_left
        style = 'right' if match_right

        insert_tag(HANDLEBARS_TEMPLATE_ASSET_IMAGE % [match[1].to_i, style])
      end

      # Strip the <img> tags out of the node. Inserts template tags for each image removed.
      def strip_images(node)
        node.css('img').each do |img|
          process_image(img)
          img.remove
        end

        node
      end

      def get_chunk(node)
        case node.name.to_sym
        when :h1, :h2, :h3, :h4, :h5, :h6, :p, :blockquote
          node.to_s
        when :img
          nil
        else
          nil
        end
      end

      def get_template_tag(node, current_chunk_index)
        case node.name.to_sym
        when :h1, :h2, :h3, :h4, :h5, :h6, :p, :blockquote
          HANDLEBARS_TEMPLATE_VERBATIM % current_chunk_index
        when :img
        end
      end

      def insert_tag(tag)
        @template << tag
      end
  end
end