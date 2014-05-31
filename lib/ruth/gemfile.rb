# Ruth Gemfile what
module Ruth
  # Gemfile generator
  class Gemfile
    attr_accessor :conf, :output

    def initialize
      @output = []
    end

    # Public - Set @conf with filled YAML data
    #
    # conf  - Array YAML list
    #
    # Returns nil
    def set_conf(conf)
      @conf = conf
    end

    # Public - Generate Gemfile
    #
    # Returns Array
    def generate(conf = nil)

      if @conf.nil?
        fail "Please use set_conf() method or provide conf for generate()"
      else
        @conf = conf
      end

      iterate
      @output
    end

    private

    # Private  - Go trough provided keys and generate output
    #
    # Returns nil
    def iterate
      @conf.keys.map do |key|
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
      @conf[:source].each do |h|
        @output << "source '#{h}'"
      end
    end

    # Private - Generate gem list depending on type
    #
    # Returns nil
    def general_list
      @conf[:general].each do |g|
        if g.kind_of?(String)
          @output << "gem '#{g}'"
        elsif g.kind_of?(Hash)
          detailed_gem_list(g)
        end
      end
    end

    # Private - Generate "gem" line depending onthe provided options
    #
    # Returns nil
    def detailed_gem_list(hash)
      gem = []

      hash.keys.map do |key|
        case key
        when :name
          gem << "gem '#{hash[:name]}'"
        when :git
          gem << ":git => '#{hash[:git]}'"
        when :branch
          gem << ":branch => '#{hash[:branch]}'"
        when :version
          case hash[:version]
          when />=/, /~>/, /</
            gem << hash[:version]
          else
            fail "Please provide correct version: ~> #{hash[:version]} / >= \
  #{hash[:version]}"
          end
        when :require
          gem << ":require => #{hash[:require]}"
        when :group
          if hash[:group].kind_of?(String)
            gem << ":group => #{hash[:group]}"
          elsif hash[:group].kind_of?(Array)
            gem << ":group => [#{hash[:group].join(', ')}]"
          end
        end
      end
      @output << gem.join(', ')
    end
  end
end
