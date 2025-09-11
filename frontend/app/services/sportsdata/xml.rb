module SportsData
  class XML

    attr_reader :element, :children

    def initialize(subject)
      case subject
      when String
        @element = Nokogiri::XML(subject)
      when Nokogiri::XML::NodeSet, Nokogiri::XML::Element
        @element = subject
      end
    end

    def [](selector)
      *css, attr = selector.split(' ')
      if css.empty?
        # go deeper by returning a new XML element
        child = element.css(attr).first
        element[attr] || (child && XML.new(child))
      else
        # this is the final segment in the selector
        element.css(css.join(' ')).first.try :[], attr
      end
    end

    def text(text)
      element.css(text).first.text
    end

    def each(selector, &block)
      element.css(selector).each do |child|
        yield XML.new(child)
      end
    end

    def child?(selector)
      element.css(selector).present?
    end

  end
end