module Techplater
  class Parser
    attr_reader :chunks

    HANDLEBARS_TEMPLATE_VERBATIM = '{{{chunks.[%d]}}}'
    HANDLEBARS_TEMPLATE_ASSET_IMAGE = '<img src="{{imagePath %d}}" />'
    ASSET_IMAGE_SRC_REGEX = /\/images\/(\d+)\/direct/

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
    #   helper imagePath: returns the displayable image path of the image model with given id

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

        # When an elements consists of solely images, it will become empty after the images are stripped. In that case, skip the element to avoid unnecessary chunks.
        return if node.content.strip.empty?

        case node.name.to_sym
        when :h1, :h2, :h3, :h4, :h5, :h6, :p, :blockquote
          # Verbatim elements. Just create a chunk and insert as-is
          @chunks << node.to_s
          # Note that in handlebars the index starts at 1
          insert_tag(HANDLEBARS_TEMPLATE_VERBATIM % @chunks.size)
        end
      end

      # Strip the <img> tags out of the node. Inserts template tags for each image removed.
      def strip_images(node)
        node.css('img').each do |img|
          match = ASSET_IMAGE_SRC_REGEX.match(img['src'])

          insert_tag(HANDLEBARS_TEMPLATE_ASSET_IMAGE % match[1].to_i) if match
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