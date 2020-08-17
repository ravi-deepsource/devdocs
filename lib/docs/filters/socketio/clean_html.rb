module Docs
  class Socketio
    class CleanHtmlFilter < Filter
      def call
        @doc = at_css(".entry-content")

        css("p > br").each do |node|
          node.remove unless /\s*-/.match?(node.next.content)
        end

        css("h1, h2, h3").each do |node|
          next if node == doc.first_element_child
          node.name = node.name.sub(/\d/) { |i| i.to_i + 1 }
          node["id"] = node.content.strip.parameterize
        end

        css("pre").each do |node|
          node.content = node.content
          node["data-language"] = /\A\s*</.match?(node.content) ? "html" : "javascript"
        end

        doc
      end
    end
  end
end
