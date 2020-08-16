module Docs
  class Ansible
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        name = at_css("h1").content.strip
        name.remove! "\u{00B6}"
        name.remove! %r{ - .*}
        name.remove! "Introduction To "
        name.remove! %r{ Guide\z}
        name
      end

      def get_type
        if version == "2.4"
          if slug.include?("module")
            if name =~ /\A[a-z]/ && node = css(".toctree-l2.current").last
              return "Modules: #{node.content.remove(" Modules")}"
            else
              return "Modules"
            end
          end
        end

        if /\Acli\//.match?(slug)
          "CLI Reference"
        elsif /\Anetwork\//.match?(slug)
          "Network"
        elsif /\Aplugins\//.match?(slug)
          if name =~ /\A[a-z]/ && node = css(".toctree-l3.current").last
            "Plugins: #{node.content.sub(/ Plugins.*/, "")}"
          else
            "Plugins"
          end
        elsif /\Amodules\//.match?(slug)
          if slug =~ /\Amodules\/list_/ || slug =~ /_maintained\z/
            "Modules: Categories"
          else
            "Modules"
          end
        elsif slug.include?("playbook")
          "Playbooks"
        elsif /\Auser_guide\//.match?(slug)
          "Guides: User"
        elsif /\Ascenario_guides\//.match?(slug)
          "Guides: Scenarios"
        elsif slug.include?("guide")
          "Guides"
        else
          "Miscellaneous"
        end
      end
    end
  end
end
