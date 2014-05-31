# Ruth Gemfile what
module Ruth
  class Gemfile
    attr_accessor :conf, :output
    def initialize(conf)
      @conf = conf
      @output = []
    end

    # GO and make stuff
    def generate
      iterate
      puts @output.join('\n')
    end

    private

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

    def sources
      @conf[:source].each do |h|
        @output << "source '#{h}'"
      end
    end

    # Private - Generate gem list
    def general_list
      @conf[:general].each do |g|
        if g.kind_of?(String)
          @output << "gem '#{g}'"
        elsif g.kind_of?(Hash)
          detailed_gem_list(g)
        end
      end
    end

    # Private what
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
