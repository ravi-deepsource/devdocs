module Docs
  class Php
    class InternalUrlsFilter < Filter
      def call
        return doc if context[:fixed_internal_urls]

        if subpath.start_with?("book.", "class.")
          result[:internal_urls] = internal_urls
        end

        doc
      end

      def internal_urls
        css(".book a", ".chunklist a").each_with_object [] do |link, urls|
          urls << link["href"] if link.next.try(:text?) && link["href"].exclude?("ref.pdo-")
        end
      end
    end
  end
end
