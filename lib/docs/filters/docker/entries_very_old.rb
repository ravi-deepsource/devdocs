module Docs
  class Docker
    class EntriesVeryOldFilter < Docs::EntriesFilter
      def get_name
        name = nav_link ? nav_link.content.strip : at_css("#content h1").content.strip
        name.capitalize! if name == "exoscale"

        if /\A[a-z\-\s]+\z/.match?(name)
          name.prepend "docker " if /engine\/reference\/commandline\/./.match?(subpath)
          name.prepend "docker-compose  " if /compose\/reference\/./.match?(subpath)
          name.prepend "docker-machine " if /machine\/reference\/./.match?(subpath)
          name.prepend "swarm " if subpath =~ /swarm\/reference\/./ && name != "swarm"
        else
          name << " (#{product})" unless /#{product}/i.match?(name)
        end

        name
      end

      def get_type
        unless nav_link
          return "Engine: User guide" if subpath.start_with?("engine/userguide")
        end

        type = nav_link.ancestors("article").to_a.reverse.to_a[0..1].map { |node|
          node.at_css("> button").content.strip
        }.join(": ")

        type.remove! %r{\ADocker }
        type.remove! %r{ Engine}
        type.sub! %r{Command[\-\s]line reference}i, "CLI"
        type = "Engine: Reference" if type == "Engine: reference"
        type
      end

      def nav_link
        return @nav_link if defined?(@nav_link)
        @nav_link = at_css("#multiple .active")

        unless @nav_link
          link = at_css("#content li a")
          return unless link
          link = at_css("#multiple a[href='#{link["href"]}']")
          return unless link
          @nav_link = link.ancestors("article").first.at_css("button")
        end

        @nav_link
      end

      def product
        @product ||= subpath.split("/").first.capitalize
      end
    end
  end
end
