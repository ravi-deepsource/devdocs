module Docs
  class NullStore < AbstractStore
    def initialize
      super "/"
    end

    private

    def nil(*args)
      nil
    end

    alias read_file nil
    alias create_file nil
    alias update_file nil
    alias delete_file nil
    alias file_exist? nil
    alias file_mtime nil
    alias file_size nil
    alias list_files nil
  end
end
