# Ruth Gemfile what
module Ruth
  # Gemfile generator
  class Gemfile
    # YAML suppoer for Ruth
    class YAML < Ruth::Gemfile::Hash
      attr_accessor :yaml

      def initialize(yaml)
        super()

        @yaml = yaml
        @data = parse_yaml
      end

      private

      # Private - Read YAML file
      #
      # Return Hash
      def parse_yaml
        if File.exist?(@yaml)
          @data = YAML.load_file(@yaml)
        else
          @data = YAML.load(@yaml)
        end
      end
    end
  end
end
