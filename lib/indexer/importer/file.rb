module Indexer

  class Importer

    # Import metadata from individual files.
    #
    module FileImportation

      #
      # Files import procedure.
      #
      def import(source)
        if File.directory?(source)
          load_directory(source)
          true
        else
          super(source) if defined?(super)
        end
      end

      #
      # Import files from a given directory. This will only import files
      # that have a name corresponding to a metadata attribute, unless
      # the file name is listed in the `customs` file within the directory.
      #
      # However, files with an extension of `.index` will be loaded as YAML
      # wholeclothe and not as a single attribute.
      #
      # @todo Subdirectories are simply omitted. Maybe do otherwise in future?
      #
      def load_directory(folder)
        if File.directory?(folder)
          customs = read_customs(folder)

          files = Dir[File.join(folder, '*')]

          files.each do |file|
            next if File.directory?(file)
            name = File.basename(file).downcase
            next load_yaml(file) if File.extname(file) == '.index'
            next load_field_file(file) if customs.include?(name)
            next load_field_file(file) if metadata.attributes.include?(name.to_sym)
          end
        end
      end

      #
      # Import a field setting from a file.
      #
      # TODO: Ultimately support JSON and maybe other types, and possibly
      # use mime-types library to recognize them.
      #
      def load_field_file(file)
        if File.directory?(file)
          # ...
        else
          case File.extname(file).downcase
          when '.yaml', '.yml'
            name = File.basename(file).downcase
            name = name.chomp('.yaml').chomp('.yml')
            metadata[name] = YAML.load_file(file)
            # TODO: should yaml files with explict extension by merged instead?
            #metadata.merge!(YAML.load_file(file))
          when '.text', '.txt'
            name = File.basename(file).downcase
            name = name.chomp('.text').chomp('.txt')
            text = File.read(file)
            metadata[name] = text.strip
          else
            text = File.read(file)
            if /\A---/ =~ text
              name = File.basename(file).downcase
              metadata[name] = YAML.load(text)
            else
              name = File.basename(file).downcase
              metadata[name] = text.strip
            end
          end
        end
      end

      #
      def read_customs(folder)
        list = []
        file = Dir[File.join(folder, 'customs{,.*}')].first
        if file
          if %w{.yaml .yml}.include?(File.extname(file))
            list = YAML.load_file(file) || []
            raise TypeError, "index: customs is not a array" unless Array === list
          else
            text = File.read(file)
            if yaml?(text)
              list = YAML.load_file(file) || []
              raise TypeError, "index: customs is not a array" unless Array === list
            else
              list = text.split("\n")
              list = list.collect{ |pattern| pattern.strip  }
              list = list.reject { |pattern| pattern.empty? }
              list = list.collect{ |pattern| Dir[File.join(folder, pattern)] }.flatten
            end
          end
        end
        return list
      end

    end

    # Include FileImportation mixin into Builder class.
    include FileImportation

  end

end
