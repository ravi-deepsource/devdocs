module Docs
  class Rxjs
    class CleanHtmlFilter < Filter
      def call
        if root_page?
          css(".card-container").remove
          at_css("h1").content = "RxJS Documentation"
        end

        if at_css("h1").nil?
          title = subpath.rpartition("/").last.titleize
          doc.prepend_child("<h1>#{title}</h1>")
        end

        css("br", "hr", ".material-icons", ".header-link", ".breadcrumb").remove

        css(".content", "article", ".api-header", "section", ".instance-member").each do |node|
          node.before(node.children).remove
        end

        css("label", "h2 > em", "h3 > em").each do |node|
          node.name = "code"
        end

        css("h1 + code").each do |node|
          node.before("<p></p>")
          while node.next_element.name == "code"
            node.previous_element << " "
            node.previous_element << node.next_element
          end
          node.previous_element.prepend_child(node)
        end

        css("td h3", ".l-sub-section > h3", ".alert h3", ".row-margin > h3", ".api-heading ~ h3", ".api-heading + h2", ".metadata-member h3").each do |node|
          node.name = "h4"
        end

        css(".l-sub-section", ".alert", ".banner").each do |node|
          node.name = "blockquote"
        end

        css(".file").each do |node|
          node.content = node.content.strip
        end

        css(".filetree .children").each do |node|
          node.css(".file").each do |n|
            n.content = "  #{n.content}"
          end
        end

        css(".filetree").each do |node|
          node.content = node.css(".file").map(&:inner_html).join("\n")
          node.name = "pre"
          node.remove_attribute("class")
        end

        css("pre").each do |node|
          node.content = node.content.strip

          node["data-language"] = "typescript" if node["path"].try(:ends_with?, ".ts")
          node["data-language"] = "html" if node["path"].try(:ends_with?, ".html")
          node["data-language"] = "css" if node["path"].try(:ends_with?, ".css")
          node["data-language"] = "js" if node["path"].try(:ends_with?, ".js")
          node["data-language"] = "json" if node["path"].try(:ends_with?, ".json")
          node["data-language"] = node["language"].sub(/\Ats/, "typescript").strip if node["language"]
          node["data-language"] ||= "typescript" if node.content.start_with?("@")

          node.before(%(<div class="pre-title">#{node["title"]}</div>)) if node["title"]

          if node["class"]&.include?("api-heading")
            node.name = "h3"

            unless node.ancestors(".instance-method").empty?
              matches = node.inner_html.scan(/([^(& ]+)[(&]/)

              unless matches.empty? || matches[0][0] == "constructor"
                node["name"] = matches[0][0]
                node["id"] = node["name"].downcase + "-"
              end
            end

            node.inner_html = "<code>#{node.inner_html}</code>"
          end

          node.remove_attribute("path")
          node.remove_attribute("region")
          node.remove_attribute("linenums")
          node.remove_attribute("title")
          node.remove_attribute("language")
          node.remove_attribute("hidecopy")
          node.remove_attribute("class")
        end

        css("td > .overloads").each do |node|
          node.replace node.at_css(".detail-contents")
        end

        css("td.short-description p").each do |node|
          signature = node.parent.parent.next_element.at_css("h3[id]")
          signature&.after(node)
        end

        css(".method-table").each do |node|
          node.replace node.at_css("tbody")
        end

        css(".api-body > table > caption").each do |node|
          node.name = "center"
          lift_out_of_table node
        end

        css(".api-body > table > tbody > tr:not([class]) > td > *").each do |node|
          lift_out_of_table node
        end

        css(".api-body > table").each do |node|
          node.remove if node.content.strip.blank?
        end

        css("h1[class]").remove_attr("class")
        css("table[class]").remove_attr("class")
        css("table[width]").remove_attr("width")
        css("tr[style]").remove_attr("style")

        css("code code").each do |node|
          node.before(node.children).remove
        end

        doc
      end

      def lift_out_of_table(node)
        table = node.ancestors("table").first
        table.previous_element.after(node)
      end
    end
  end
end
