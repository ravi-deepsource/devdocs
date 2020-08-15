module Docs
  class Codeception
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        name = (at_css(".js-algolia__initial-content h1") || at_css(".js-algolia__initial-content h2")).content

        if number = subpath[/\A\d+/]
          name.prepend "#{number.to_i}. "
        end

        name
      end

      def get_type
        if /\d\d/.match?(subpath)
          "Guides"
        elsif subpath.start_with?("modules")
          "Module: #{name}"
        elsif name.include?("Util")
          "Util Class: #{name.split('\\').last}"
        else
          "Reference: #{name}"
        end
      end

      def additional_entries
        if /Module/.match?(type)
          prefix = "#{name}::"
          pattern = at_css("#actions") ? "#actions ~ h4" : "#page h4"
        elsif /Functions/.match?(type)
          prefix = ""
          pattern = "#page h4"
        elsif /Util/.match?(name)
          prefix = "#{name.remove('Codeception\\Util\\')}::"
          pattern = "#page h4"
        elsif /(Commands)|(Configuration)/.match?(type)
          prefix = ""
          pattern = "h2"
        end

        return [] unless pattern

        css(pattern).map { |node|
          [prefix + node.content, node["id"]]
        }.compact
      end
    end
  end
end
