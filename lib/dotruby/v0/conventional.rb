if RUBY_VERSION > '1.9'
  require_relative 'attributes'
  require_relative 'conversion'
  require_relative 'requirement'
  require_relative 'dependency'
  require_relative 'resource'
  require_relative 'conflict'
  require_relative 'author'
  require_relative 'copyright'
else
  require 'dotruby/v0/attributes'
  require 'dotruby/v0/conversion'
  require 'dotruby/v0/requirement'
  require 'dotruby/v0/dependency'
  require 'dotruby/v0/conflict'
  require 'dotruby/v0/resource'
  require 'dotruby/v0/author'
  require 'dotruby/v0/copyright'
end

module DotRuby

  module V0

    # Conventional interface for DotRuby specification provides convenience 
    # for developers. It offers method aliases and models various parts of 
    # the specification with useful classes.
    #
    module Conventional

      include Attributes
      include Conversion

      # -- Writers ------------------------------------------------------------

      # Internal sources for building .ruby file.
      #
      # @param [String, Array] path(s)
      #   Paths from which .ruby can extract specification information.
      #
      def source=(list)
        @data['source'] = [list].flatten
      end

      # Sets the name of the project.
      #
      # @param [String] name
      #   The new name of the project.
      #
      def name=(name)
        name = name.to_s if Symbol === name
        Valid.name!(name, :name)
        @data['name']  = name.to_str.downcase
        @data['title'] = @data['name'].capitalize unless @data['title']  # TODO: use #titlecase
        @data['name']
      end

      # Title is sanitized so that all white space is reduced to a
      # single space character.
      #
      def title=(title)
        Valid.oneline!(title, :title)
        @data['title'] = title.to_str.gsub(/\s+/, ' ')
      end

      #
      # The toplevel namespace of API, e.g. `module Foo` or `class Bar`,
      # would be `"Foo"` or `"Bar"`, repectively.
      #
      # @param [String] namespace
      #   The new toplevel namespace of the project's API.
      #
      def namespace=(namespace)
        Valid.constant!(namespace)
        @data['namespace'] = namespace
      end

      #
      # Summary is sanitized to only have one line of text.
      #
      def summary=(summary)
        Valid.string!(summary, :summary)
        @data['summary'] = summary.to_str.gsub(/\s+/, ' ')
      end

      #
      # Sets the version of the project.
      #
      # @param [Hash, String, Array, Version::Number] version
      #   The version from the metadata file.
      #
      # @raise [ValidationError]
      #   The version must either be a `String`, `Hash` or `Array`.
      #
      def version=(version)
        case version
        when Version::Number
          @data['version'] = version
        when Hash
          major = version['major'] || version[:major]
          minor = version['minor'] || version[:minor]
          patch = version['patch'] || version[:patch]
          build = version['build'] || version[:build]
          @data['version'] = Version::Number.new(major,minor,patch,build)
        when String
          @data['version'] = Version::Number.parse(version.to_s)
        when Array
          @data['version'] = Version::Number.new(*version)
        else
          raise(ValidationError,"version must be a Hash or a String")
        end
      end

      #
      # Codename is the name of the particular version.
      #
      def codename=(codename)
        codename = codename.to_s if Symbol === codename
        Valid.oneline!(codename, :codename)
        @data['codename'] = codename.to_str
      end

      #
      # Sets the production date of the project.
      #
      # @param [String,Date,Time,DateTime] date
      #   The production date for this version.
      #
      def date=(date)
        @data['date'] = \
          case date
          when String
            Date.parse(date)
          when Date, Time, DateTime
            date
          else
            raise ValidationError, "invalid date for `date' - #{date.inspect}"
          end
      end

      #
      # Sets the creation date of the project.
      #
      # @param [String,Date,Time,DateTime] date
      #   The creation date of this project.
      #
      def created=(date)
        @data['created'] = \
          case date
          when String
           Valid.utc_date!(date)
           Date.parse(date)
          when Date, Time, DateTime
           date
          else
           raise ValidationError, "invalid date for `created' - #{date.inspect}"
          end
      end

      # Set the copyrights and licenses for the project.
      #
      # Copyrights SHOULD be in order of significance. The first license 
      # given is taken to be the project's primary license.
      #
      # License fields SHOULD be offically recognized identifiers such
      # as "GPL-3.0" as defined by SPDX (http://). 
      #
      # @example
      #    spec.copyrights = [ 
      #      {
      #        'year'    => '2010',
      #        'holder'  => 'Thomas T. Thomas',
      #        'license' => "MIT"
      #      }
      #    ]
      #
      # @param [Array<Hash,String,Array>]
      #   The copyrights and licenses of the project.
      #
      def copyrights=(copyrights)
        @data['copyrights'] = \
          case copyrights
          when String
            [Copyright.parse(copyrights, @_license)]
          when Hash
            [Copyright.parse(copyrights, @_license)]
          when Array
            copyrights.map do |copyright|
              Copyright.parse(copyright, @_license)
            end
          else
            raise(ValidationError, "copyright must be a String, Hash or Array")
          end
        @data['copyrights']
      end

      #
      # Singular form of `#copyrights=`. This is similar to `#copyrights=`
      # but expects the parameter to represent only one copyright.
      #
      def copyright=(copyright)
        @data['copyrights'] = [Copyright.parse(copyright)]
      end

      # TODO: Should their just be a "primary" license field ?

      #
      # Set copyright license for all copyright holders.
      #
      def license=(license)
        if copyrights = @data['copyrights']
          copyrights.each do |c|
            c.license = license  # TODO: unless c.license ?
          end
        end
        @_license = license
      end

      # Set the authors of the project.
      #
      # @param [Array<String>, String] authors
      #   The originating authors of the project.
      #
      def authors=(authors)
        @data['authors'] = (
          list = Array(authors).map do |a|
                   Author.parse(a)
                 end
          warn "Duplicate authors listed" if list != list.uniq
          list
        )
      end

      # TODO: should we warn if directory does not exist?

      # Sets the require paths of the project.
      #
      # @param [Array<String>, String] paths
      #   The require-paths or a glob-pattern.
      #
      def load_path=(paths)
        @data['load_path'] = \
          Array(paths).map do |path|
            Valid.path!(path)
            path
          end
      end

      # List of language engine/version family supported.
      def engines=(value)
        @data['engines'] = (
          a = [value].flatten
          a.each{ |x| Valid.oneline!(x) }
          a
        )
      end

      # List of platforms supported.
      def platforms=(value)
        @data['platforms'] = (
          a = [value].flatten
          a.each{ |x| Valid.oneline!(x) }
          a
        )
      end

      #
      # Sets the requirements of the project. Also commonly refered
      # to as dependencies.
      #
      # @param [Array<Hash>, Hash{String=>Hash}, Hash{String=>String}] requirements
      #   The requirement details.
      #
      # @raise [ValidationError]
      #   The requirements must be an `Array` or `Hash`.
      #
      def requirements=(requirements)
        requirements = [requirements] if String === requirements
        case requirements
        when Array, Hash
          @data['requirements'].clear
          requirements.each do |specifics|
            @data['requirements'] << Requirement.parse(specifics)
          end
        else
          raise(ValidationError,"requirements must be an Array or Hash")
        end
      end

      #
      # Binary pacakge dependecies.
      #
      # @param [Array<Hash>, Hash{String=>Hash}, Hash{String=>String}] requirements
      #   The dependency details.
      #
      # @raise [ValidationError]
      #   The dependencies must be an `Array` or `Hash`.
      #
      def dependencies=(dependencies)
        case dependencies
        when Array, Hash
          @data['dependencies'].clear
          dependencies.each do |specifics|
            @data['dependencies'] << Dependency.parse(specifics)
          end
        else
          raise(ValidationError,"dependencies must be an Array or Hash")
        end
      end

      #
      # Sets the packages with which this package is known to have
      # incompatibilites.
      #
      # @param [Array<Hash>, Hash{String=>String}] conflicts
      #   The conflicts for the project.
      #
      # @raise [ValidationError]
      #   The conflicts list must be an `Array` or `Hash`.
      #
      # @todo lets get rid of the type check here and let the #parse method do it
      def conflicts=(conflicts)
        case conflicts
        when Array, Hash
          @data['conflicts'].clear
          conflicts.each do |specifics|
            @data['conflicts'] << Conflict.parse(specifics)
          end
        else
          raise(ValidationError, "conflicts must be an Array or Hash")
        end
      end

      #
      # Sets the packages this package could (more or less) replace.
      # 
      # @param [Array<String>] alternatives
      #   The alternatives for the project.
      #
      def alternatives=(alternatives)
        Valid.array!(alternatives, :alternatives)

        @data['alternatives'].clear

        alternatives.to_ary.each do |name|
          @data['alternatives'] << name.to_s
        end
      end

      #
      # Sets the categories for this project.
      # 
      # @param [Array<String>] categories
      #   List of purpose categories for the project.
      #
      def categories=(categories)
        Valid.array!(categories, :categories)

        @data['categories'].clear

        categories.to_ary.each do |name|
          Valid.oneline!(name.to_s)
          @data['categories'] << name.to_s
        end
      end

      #
      # Suite must be a single line string.
      #
      # @param [String] suite
      #   The suite to which the project belongs.
      #
      def suite=(value)
        Valid.oneline!(value, :suite)
        @data['suite'] = value
      end

      #
      # Sets the repostiories this project has.
      # 
      # @param [Array<String>, Hash] repositories
      #   The repositories for the project.
      #
      def repositories=(repositories)
        case repositories
        when Hash, Array
          @data['repositories'].clear
          repositories.each do |specifics|
            @data['repositories'] << Repository.parse(specifics)
          end
        else
          raise(ValidationError, "repositories must be an Array or Hash")
        end
      end

      #
      # Set the resources for the project.
      #
      # @param [Array,Hash] resources
      #   A list or map of resources.
      #
      def resources=(resources)
        case resources
        when Array
          @data['resources'].clear
          resources.each do |specifics|
            @data['resources'] << Resource.parse(specifics)
          end
        when Hash
          @data['resources'].clear
          resources.each do |type, uri|
            @data['resources'] << Resource.new(:uri=>uri, :type=>type)
          end
        else
          raise(ValidationError, "repositories must be an Array or Hash")
        end
      end

      #
      # The webcvs prefix must be a valid URI.
      #
      # @param [String] uri
      #   The webcvs prefix, which must be a valid URI.
      #
      def webcvs=(uri)
        Valid.uri!(uri, :webcvs)
        @data['webcvs'] = uri
      end

      #
      # Set the orgnaization to which the project belongs.
      #
      # @param [String] organization
      #   The name of the organization.
      #
      def organization=(organization)
        Valid.oneline!(organization)
        @data['organization'] = organization
      end

      #
      # Sets the post-install message of the project.
      #
      # @param [Array, String] message
      #   The post-installation message.
      #
      # @return [String]
      #   The new post-installation message.
      #
      def install_message=(message)
        @data['install_message'] = \
          case message
          when Array
            message.join($/)
          else
            Valid.string!(message)
            message.to_str
          end
      end

      #
      # Set extraneous developer-defined metdata.
      #
      def extra=(extra)
        unless extra.kind_of?(Hash)
          raise(ValidationError, "extra must be a Hash")
        end
        @data['extra'] = extra
      end

      # -- Utility Methods ----------------------------------------------------

      #
      # Adds a new requirement.
      #
      # @param [String] name
      #   The name of the requirement.
      #
      # @param [Hash] specifics
      #   The specifics of the requirement.
      #
      def add_requirement(name, specifics)
        requirements << Requirement.parse([name, specifics])
      end

      #
      # Adds a new dependency.
      #
      # @param [String] name
      #   The name of the dependency.
      #
      # @param [Hash] specifics
      #   The specifics of the dependency.
      #
      def add_dependency(name, specifics)
        dependencies << Dependency.parse([name, specifics])
      end

      #
      # Adds a new conflict.
      #
      # @param [String] name
      #   The name of the conflict package.
      #
      # @param [Hash] specifics
      #   The specifics of the conflict package.
      #
      def add_conflict(name, specifics)
        conflicts << Requirement.parse([name, specifics])
      end

      #
      # Adds a new alternative.
      #
      # @param [String] name
      #   The name of the alternative.
      #
      def add_alternative(name)
        alternatives << name.to_s
      end

      #
      #
      #
      def add_repository(id, url, scm=nil)
        repositories << Repository.parse(:id=>id, :url=>url, :scm=>scm)
      end

      #
      # A specification is not valid without a name and version.
      #
      # @return [Boolean] valid specification?
      #
      def valid?
        return false unless name
        return false unless version
        true
      end


# TODO: What was used for again, load_path ?
=begin
      #
      # Iterates over the paths.
      #
      # @param [Array<String>, String] paths
      #   The paths or path glob pattern to iterate over.
      #
      # @yield [path]
      #   The given block will be passed each individual path.
      #
      # @yieldparam [String] path
      #   An individual path.
      #
      def each_path(paths,&block)
        case paths
        when Array
          paths.each(&block)
        when String
          Dir.glob(paths,&block)  # TODO: should we be going this?
        else
          raise(ValidationError, "invalid path")
        end
      end

      private :each_path
=end

      # -- Calculations -------------------------------------------------------

      #
      # The primary copyright of the project.
      #
      # @return [String]
      #   The primary copyright for the project.
      #
      def copyright
        copyrights.join("\n")
      end

      #
      # The primary email address of the project. The email address
      # is taken from the first listed author.
      #
      # @return [String, nil]
      #   The primary email address for the project.
      #
      def email
        authors.find{ |a| a.email }
      end

      #
      # Get homepage URI.
      #
      def homepage #(uri=nil)
        #uri ? self.homepage = url
        resources.each do |r|
          if r.type == 'home'
            return r.uri
          end
        end
      end
      alias_method :website, :homepage

      #
      # Convenience method for setting a `hompage` resource.
      #
      # @todo Rename to website?
      #
      def homepage=(uri)
        resource = Resource.new(:name=>'homepage', :type=>'home', :uri=>uri)
        resources.unshift(resource)
        uri
      end
      alias_method :website=, :homepage=

      #
      # Returns the runtime requirements of the project.
      #
      # @return [Array<Requirement>] runtime requirements.
      def runtime_requirements
        requirements.select do |requirement|
          requirements.runtime?
        end
      end

      #
      # Returns the runtime dependencies of the project.
      #
      # @return [Array<Dependency>] runtime dependencies.
      def runtime_dependencies
        dependecies.select do |dependency|
          dependency.runtime?
        end
      end

      #
      # Returns the development requirements of the project.
      #
      # @return [Array<Requirement>] development requirements.
      #
      def development_requirements
        requirements.select do |requirement|
          ! requirements.runtime?
        end
      end

      #
      # Returns the development dependencies of the project.
      #
      # @return [Array<Dependency>] development dependencies.
      def development_dependencies
        dependecies.select do |dependency|
          ! dependency.runtime?
        end
      end

      # -- Aliases ------------------------------------------------------------

      #
      #
      # @return [Array] load paths
      def loadpath
        load_path
      end

      #
      # RubyGems term for #load_path.
      #
      def loadpath=(value)
        self.load_path = value
      end

      #
      #
      # @return [Array] load paths
      def require_paths
        load_path
      end

      #
      # RubyGems term for #load_path.
      #
      def require_paths=(value)
        self.load_path = value
      end

      #
      # Alternate short name for #requirements.
      #
      def requires
        requirements
      end

      #
      # Alternate short name for #requirements.
      #
      def requires=(value)
        self.requirements = value
      end

      #
      # Alternate singular form of #engines.
      #
      def engine=(value)
        self.engines = value
      end

      #
      # Alternate singular form of #platforms.
      #
      def platform=(value)
        self.platforms = value
      end

      # -- Conversion ---------------------------------------------------------

      #
      # Convert convenience form of metadata to canonical form.
      #
      # @todo: Make sure this generates the canonical form.
      #
      def to_h
        date = self.date || Time.now

        data = @data.dup

        data['version']      = version.to_s

        data['date']         = date.strftime('%Y-%m-%d')
        data['created']      = created.strftime('%Y-%m-%d') if created

        data['authors']      = authors.map      { |x| x.to_h }
        data['copyrights']   = copyrights.map   { |x| x.to_h }
        data['requirements'] = requirements.map { |x| x.to_h }
        data['conflicts']    = conflicts.map    { |x| x.to_h }
        data['repositories'] = repositories.map { |x| x.to_h }
        data['resources']    = resources.map    { |x| x.to_h }

        data
      end

    protected

      #
      # Initializes the {Metadata} attributes.
      #
      def initialize_attributes
        super
      end

    end

  end

end
