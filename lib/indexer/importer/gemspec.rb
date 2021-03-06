module Indexer

  class Importer

    # It is not the recommended that a .gemspec be the usual source of metadata.
    # Rather it is recommended that a the gemspec be produced from the metadata
    # instead. (Rumber's metadata covers almost every aspect of a emspec, and
    # a gemspec can be augmented where needed.) Nonetheless, a gemspec can serve
    # as a good soruce for creating an initial metadata file.
    #
    module GemspecImportation

      #
      # If the source file is a gemspec, import it.
      #
      def import(source)
        case File.extname(source)
        when '.gemspec'
          # TODO: handle YAML-based gemspecs
          gemspec = ::Gem::Specification.load(source)
          metadata.import_gemspec(gemspec)
          true
        else
          super(source) if defined?(super)
        end
      end

      #
      #def local_files(root, glob, *flags)
      #  bits = flags.map{ |f| File.const_get("FNM_#{f.to_s.upcase}") }
      #  files = Dir.glob(File.join(root,glob), bits)
      #  files = files.map{ |f| f.sub(root,'') }
      #  files
      #end
    end

    # Include GemspecImportation mixin into Builder class.
    include GemspecImportation

  end

end

