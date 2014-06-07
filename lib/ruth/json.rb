module Ruth
  class Gemfile
    # JSON suppoer for Ruth
    class JSON
      attr_accessor :json

      def initialize(json)
        @json = json
        @data = parse_json_file
      end

      private

      # Private - Read JSON file
      #
      # Return Hash
      def parse_json_file
        if File.exist?(@file)
          JSON.parse(IO.readlines(@file))
        else
          JSON.parse(@file)
        end
      end
    end
  end
end
