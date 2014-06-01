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
          @gem<< "source '#{h}'"
        end
      end
    end

    # Private - Generate gem list depending on type
    #
    # Returns nil
    def general_list
      @data[:general].each do |g|
        if g.kind_of?(String)
          @gem<< "gem '#{g}'"
        elsif g.kind_of?(Hash)
          detailed_gem_list(g)
        end
      end
    end

    # Private - Generate "gem" line depending onthe provided options
    #
    # Returns nil
    def detailed_gem_list(hash)
      items = []
      hash.keys.map do |key|
        case key
        when :name
          items << "gem '#{hash[key]}'"
        when :git
          items << ":git => '#{hash[key]}'"
        when :branch
          items << ":branch => '#{hash[key]}'"
        when :version
          items << verify_version
        when :require
          items << ":require => #{hash[key]}"
        when :group
          items << gem_group
        end
      end
      @gem << items.join(', ')
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
        gem << version
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
