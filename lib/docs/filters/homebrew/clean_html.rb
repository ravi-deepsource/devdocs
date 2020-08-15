module Docs
  class Homebrew
    class CleanHtmlFilter < Filter
      def call
        css("hr")

        if at_css("h1").nil?
          title = current_url.normalized_path[1..-1].tr("-", " ")
          doc.children.before("<h1>#{title}</h1>")
        end

        css("div.highlighter-rouge").each do |node|
          lang = node["class"][/language-(\w+)/, 1]
          node["data-language"] = lang if lang
          node.content = node.content.strip
          node.name = "pre"
          node.remove_attribute("class")
        end

        doc
      end
    end
  end
end
