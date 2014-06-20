# Ruth Gemfile what
module Ruth
  # Gemfile generator
  class Gemfile
    # Hash parser
    class Hash
      attr_accessor :file, :gem, :gemfile
      attr_writer :data

      def initialize
        @gem = []
      end

      # Public - Generate Gemfile contents
      #
      # Returns Array
      def output
        parse_gemfile_item
        @gem.join("\n")
      end

      private

      # Private  - Go trough provided keys and generate output
      #
      # Returns nil
      def parse_gemfile_item
        @data.keys.map do |key|
          case key
          when :source then sources
          when :general then general_list
          when :group then group_list
          end
        end
      end

      # Private - Fill in source list
      #
      # Returns nil
      def sources
        case @data[:source]
        when String then gem << "source '#{@data[:source]}"
        when Array then @data[:source].each { |h| @gem << "source '#{h}'" }
        end
        @gem << ''
      end

      # Private - Generate gem list depending on type
      #
      # Returns nil
      def general_list
        @data[:general].each { |g| gem_list(g) }
      end

      # Private - Generate gem group
      #
      # Returns nil
      def group_list
        @data[:group].each do |group|
          @gem << gem_group(group[:group_name])
          group[:gems].each { |item| gem_list(item, true) }
          @gem << "end\n"
        end
      end

      # Private - Create gem listing from a provided Array or Hash
      #
      # item - Array or Hash gem list
      # tab - nil/true add tab indentation
      #
      # Returns nil
      def gem_list(item, tab = nil)
        item.key?(:name)
      rescue NoMethodError
        @gem << format_gem_item(item, tab)
      else
        @gem << detailed_gem_list(item, tab)
      end

      # Private - Generate "gem" line depending onthe provided options
      #
      # hash - Hash Gem definition
      # format - true/false states if tabbed formatting should be added
      #
      # Returns Array
      def detailed_gem_list(hash, format)
        items = []
        hash.keys.map do |key|
          case key
          when :name then items << format_gem_item(hash[key], format)
          when :version then items << verify_version(hash[key])
          when :group then items << gem_group
          else items << gem_inline_item(key, hash[key])
          end
        end
        items.join(', ')
      end

      # Private - Outputs gem line formatted or not
      #
      # gem - String gem line
      # formatting - true/false
      #
      # Returns String
      def format_gem_item(gem, format)
        if format
          "  gem '#{gem}'"
        else
          "gem '#{gem}'"
        end
      end

      # Private - Return String for Gem line of additional options
      #
      # item - String name of the definition
      # value - String value to assing
      #
      # Return String
      def gem_inline_item(item, value)
        ":#{item} => '#{value}'"
      end

      # Private - Check kind of group we hav
      #
      # group - Array or String of groups where gem belongs
      #
      # Returns String
      def gem_group(group)
        if group.kind_of?(String)
          "group :#{group} do"
        elsif group.kind_of?(Array)
          ":group [#{group.join(', ')}]"
        end
      end

      # Private - Check if version key data syntax is correct
      #
      # version - String
      #
      # Returns String
      def verify_version(version)
        ver = [/>=/, /~>/, /</].any? { |w| w =~ version }
        if ver
          "'#{version}'"
        else
          fail "Please provide correct version: ~> #{hash[:version]} / >= \
  #{hash[:version]}"
        end
      end
    end
  end
end
