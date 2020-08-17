module Docs
  class Rdoc
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        name = at_css("h1, h2").content.strip
        name.remove! "\u{00B6}" # remove pilcrow sign
        name.remove! "\u{2191}" # remove up arrow sign
        name.remove! "class "
        name.remove! "module "
        name
      end

      def get_type
        type = name.dup

        unless type.gsub! %r{::.*\z}, ""
          parent = at_css(".meta-parent").try(:content).to_s
          return "Errors" if type.end_with?("Error") || parent.end_with?("Error") || parent.end_with?("Exception")
        end

        type
      end

      def include_default_entry?
        at_css("> .description p") || css(".documentation-section").any? { |node| node.content.present? }
      end

      IGNORE_METHODS = %w[version gem_version]

      def additional_entries
        return [] if root_page?
        require "cgi"

        css(".method-detail").each_with_object [] do |node, entries|
          name = node["id"].dup
          name.remove! %r{\A\w+?-.}
          name.remove! %r{\A-(?!\d)}
          name.tr! "-", "%"
          name = CGI.unescape(name)

          unless name.start_with?("_") || IGNORE_METHODS.include?(name)
            name.prepend self.name + (/\A\w+-c-/.match?(node["id"]) ? "::" : "#")
            entries << [name, node["id"]] unless entries.any? { |entry| entry[0] == name }
          end
        end
      end
    end
  end
end
