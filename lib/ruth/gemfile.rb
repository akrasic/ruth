# Ruth Gemfile what
module Ruth
  # Gemfile generator
  class Gemfile
    attr_accessor :file, :data, :gem, :gemfile

    def initialize(yaml_file)
      @gem = []
      @file = yaml_file
      @data = parse_yaml_file

      parse_gemfile_items
    end

    # Public - Generate Gemfile
    #
    # Returns Array
    def final_gemfile
      @gem.join("\n")
    end

    # Public - Write parsed data into a Gemfile
    #
    # file - String location fo the file
    #
    # Returns nil
    def write_gemfile
      begin
        fd = File.open(@gemfile, 'w')
        fd.write(final_gemfile)
      ensure
        fd.close unless fd.nil?
      end
    end

    private

    # Private  - Go trough provided keys and generate output
    #
    # Returns nil
    def parse_gemfile_items
      @data.keys.map do |key|
        case key
        when :source
          sources
        when :general
          general_list
        end
      end
    end

    # Private - Fill in source list
    #
    # Returns nil
    def sources
      if @data[:source].kind_of?(String)
        @gem << "source '#{@data[:source]}"
      elsif @data[:source].kind_of?(Array)
        @data[:source].each do |h|
          @gem << "source '#{h}'"
        end
      end
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
      @data[:group].each do |gr|
        @gem << gem_group(gr[:group_name])

        gr[:gems].each { |g| gem_list(g, 1) }

        @gem << 'end'
      end
    end

    # Private - Create gem listing from a provided Array or Hash
    #
    # gems - Array or Hash gem list
    #
    # Returns nil
    def gem_list(gems, format = nil)
      if gems.kind_of?(String)
        @gem << format_gem_item(gems, format)
      elsif gems.kind_of?(Hash)
        @gem << detailed_gem_list(gems, format)
      end
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
        when :name
          items << format_gem_item(hash[key], format)
        when :version
          items << verify_version
        when :group
          items << gem_group
        else
          items << format_gem_item(key, hash[key])
        end
      end
      @gem << items.join(', ')
    end

    # Private - Outputs gem line formatted or not
    #
    # gem - String gem line
    # formatting - true/false
    #
    # Returns String
    def format_gem_item(gem, format)
      if format
        "\tgem '#{gem}'"
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
    def gem_line_item(item, value)
      "#{item} => '#{value}'"
    end

    # Private - Check kind of group we hav
    #
    # group - Array or String of groups where gem belongs
    #
    # Returns String
    def gem_group(group)
      if group.kind_of?(String)
        ":group => #{group}"
      elsif group.kind_of?(Array)
        ":group => [#{group.join(', ')}]"
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
        version
      else
        fail "Please provide correct version: ~> #{hash[:version]} / >= \
#{hash[:version]}"
      end
    end

    # Private - Read YAML file
    #
    # Return Hash
    def parse_yaml_file
      YAML.load_file(@file)
    end
  end
end
