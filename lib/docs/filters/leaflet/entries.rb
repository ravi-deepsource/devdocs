module Docs
  class Leaflet
    class EntriesFilter < Docs::EntriesFilter
      def additional_entries
        entries = []
        type = nil
        subtype = nil

        css("*").each do |node|
          if node.name == "h2" && node["id"]
            type = node.content
            subtype = nil
            entries << [type, node["id"], type]
          elsif node.name == "h3"
            subtype = node.content
          elsif node.name == "tr" && node["id"]
            value = node.css("td > code > b").first.content
            name = if subtype&.end_with?(" options")
              "#{subtype}: #{value}"
            elsif subtype
              "#{type} #{subtype.downcase}: #{value}"
            else
              "#{type}: #{value}"
            end
            entries << [name, node["id"], type]
          end
        end

        entries
      end
    end
  end
end
