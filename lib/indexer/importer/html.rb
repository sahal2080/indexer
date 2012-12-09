module Indexer

  class Importer

    # Import metadata from a HTML source using microformats.
    #
    # NOTE: The implementation using css selectors is fairly slow.
    #       If we even think it important to speed up then we might
    #       try traversing instead.
    #
    module HTMLImportation

      #
      # YAML import procedure.
      #
      def import(source)
        if File.file?(source)
          case File.extname(source)
          when '.html'
            load_html(source)
            return true
          end
        end
        super(source) if defined?(super)
      end

      #
      # Import metadata from HTML file.
      #
      def load_html(file)
        require 'nokogiri'

        case file
        when Nokogiri::XML::Document
          doc = file
        when File
          doc = Nokogiri::HTML(file)
        else
          doc = Nokogiri::HTML(File.new(file))
        end

        data = {}

        %w{version summary description created}.each do |field|
          load_html_simple(field, doc, data)
        end

        load_html_name(doc, data)
        load_html_title(doc, data)
        load_html_authors(doc, data)
        load_html_organizations(doc, data)
        load_html_requirements(doc, data)
        load_html_resources(doc, data)
        load_html_repositories(doc, data)
        load_html_copyrights(doc, data)
        load_html_categories(doc, data)

        metadata.merge!(data)
      end

      #
      # Load a simple field value.
      #
      def load_html_simple(field, doc, data)
        nodes = doc.css(".i#{field}")
        return if (nodes.nil? or nodes.empty?)
        text = nodes.first.content.strip
        data[field] = text
      end

      #
      # Load name, and use it for title too if not already set.
      #
      def load_html_name(doc, data)
        nodes = doc.css(".iname")
        return if (nodes.nil? or nodes.empty?)
        text = nodes.first.content.strip

        unless metadata.title
          data['title'] = text.capitalize
        end

        data['name'] = text
      end

      #
      # Load title, and use it for name too if not already set.
      #
      def load_html_title(doc, data)
        nodes = doc.css(".ititle")
        return if (nodes.nil? or nodes.empty?)
        text = nodes.first.content.strip

        unless metadata.name
          data['name'] = text.downcase.gsub(/\s+/, '_')
        end

        data['title'] = text
      end

      #
      #
      #
      def load_html_categories(doc, data)
        nodes = doc.css('.icategory')
        return if (nodes.nil? or nodes.empty?)

        data['categories'] ||= []

        nodes.each do |node|
          entry = node.content.strip
          data['categories'] << entry unless entry == ""
        end
      end

      #
      #
      #
      def load_html_resources(doc, data)
        nodes = doc.css('.iresource')
        return if (nodes.nil? or nodes.empty?)

        data['resources'] ||= []

        nodes.each do |node|
          entry = {}

          entry['uri']   = node.attr('href')
          entry['type']  = node.attr('name') || node.attr('title')  # best choice for this?
          entry['label'] = node.content.strip

          data['resources'] << entry if entry['uri']
        end
      end

      #
      #
      #
      def load_html_requirements(doc, data)
        nodes = doc.css('.irequirement')
        return if (nodes.nil? or nodes.empty?)

        data['requirements'] ||= []

        nodes.each do |node|
          entry = {}

          if n = node.at_css('.name')
            entry['name'] = n.content.strip
          end

          if n = node.at_css('.version')
            entry['version'] = n.content.strip
          end

          # TODO: better approach to optional field?
          if n = node.at_css('.optional')
            entry['optional'] = true  #n.content.strip != "false"
          end

          if n = (node.at_css('.groups') || node.at_css('.group'))
            text = n.content.strip
            text = text.sub(/^[(]/, '').sub(/[)]$/, '').strip
            entry['groups'] = text.split(/\s+/)

            if %w{test build document development}.any?{ |g| entry['groups'].include?(g) }
              entry['development'] = true
            end
          end

          data['requirements'] << entry if entry['name']
        end
      end

      #
      # Class is `iauthor`.
      #
      def load_html_authors(doc, data)
        nodes = doc.css('.iauthor')
        return if (nodes.nil? or nodes.empty?)

        data['authors'] ||= []

        nodes.each do |node|
          entry = {}

          if n = (node.at_css('.name') || node.at_css('.nickname'))
            entry['name'] = n.content.strip
          end

          if n = node.at_css('.email')
            text = n.attr(:href) || n.content.strip
            text = text.sub(/^mailto\:/i, '')
            entry['email'] = text
          end

          if n = node.at_css('.website') || node.at_css('.uri') || node.at_css('.url')
            text = n.attr(:href) || n.content.strip
            entry['website'] = text
          end

          data['authors'] << entry if entry['name']
        end
      end

      #
      # Class is `iorg`.
      #
      def load_html_organizations(doc, data)
        nodes = doc.css('.iorg')
        return if (nodes.nil? or nodes.empty?)

        data['organizations'] ||= []

        nodes.each do |node|
          entry = {}

          if n = node.at_css('.name')
            entry['name'] = n.content.strip
          end

          if n = node.at_css('.email')
            text = n.attr(:href) || n.content.strip
            text = text.sub(/^mailto\:/i, '')
            entry['email'] = text
          end

          if n = node.at_css('.website') || node.at_css('.uri') || node.at_css('.url')
            text = n.attr(:href) || n.content.strip
            entry['website'] = text
          end

          data['organizations'] << entry if entry['name']
        end
      end

      #
      # Class is `irepo`.
      #
      def load_html_repositories(doc, data)
        nodes = doc.css('.irepo')
        return if (nodes.nil? or nodes.empty?)

        data['repositories'] ||= []

        nodes.each do |node|
          entry = {}

          entry['uri']   = node.attr('href')
          entry['type']  = node.attr('name') || node.attr('title')  # best choice for this?
          entry['label'] = node.content.strip

          data['resources'] << entry if entry['uri']
        end
      end

      #
      #
      #
      def load_html_copyrights(doc, data)
        nodes = doc.css('.icopyright')
        return if (nodes.nil? or nodes.empty?)

        data['copyrights'] ||= []

        nodes.each do |node|
          entry = {}

          if n = node.at_css('.holder')
            entry['holder'] = n.content.strip
          end

          if n = node.at_css('.year')
            entry['year'] = n.content.strip
          end

          if n = node.at_css('.license')
            text = n.content.strip
            text = text.sub(/license$/i,'').strip
            entry['license'] = text
          end

          data['copyrights'] << entry
        end
      end

    end

    # Include YAMLImportation mixin into Builder class.
    include HTMLImportation

  end

end
