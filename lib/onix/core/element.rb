# coding: utf-8

module ONIX

  class Element

    include ROXML

    # An accessor to an array of element instances.
    #
    # Options:
    #
    #   :from - defaults to the class name, but you can override this.
    #   :singular - accessor is not an array, just a single object.
    #
    def self.onix_composite(name, klass, options = {})
      options[:as] = options.delete(:singular) ? klass : [klass]
      options[:from] ||= klass.to_s.split("::").last
      xml_accessor(name, options)
    end

    # An accessor that treats the input/output as a date.
    #
    # Options: none yet.
    #
    def self.onix_date_accessor(name, tag_name, options = {})
      options = options.merge(
        :from => tag_name,
        :to_xml => ONIX::Formatters.yyyymmdd
      )
      if options[:as].kind_of?(Array)
        prep = lambda { |vs|
          [vs].flatten.collect { |v| Date.parse(v) rescue nil }
        }
      else
        prep = lambda { |v| Date.parse(v) rescue nil }
      end
      xml_accessor(name, options, &prep)
    end

    # An accessor that treats the input as a space-separated list, and
    # creates an array for it.
    #
    def self.onix_space_separated_list(name, tag_name, options = {})
      options = options.merge(
        :from => tag_name,
        :to_xml => ONIX::Formatters.space_separated
      )
      prep = lambda { |v| v ? v.split : [] }
      xml_accessor(name, options, &prep)
    end

    # An accessor that maps a "code" string into an ONIX::Code object.
    # A Code object can return the simple code (or "key"), or the value that
    # is associated with it in ONIX code lists, and so on.
    #
    # Required:
    #
    #   :list - integer referring to an ONIX Code List
    #
    # Special options for Code instantiation are:
    #
    #   :length - how many digits to pad (default is taken from total list size)
    #
    # As well as the normal accessor (x/x=), this will create a
    # special accessor for the richer Code object (#x_code/#x_code=).
    # For example:
    #
    #   class Foo < ONIX::Element
    #     onix_code_from_list(:message_type, "MessageType", :list => 1)
    #   end
    #
    #   foo = Foo.new
    #
    #   foo.message_type = 1
    #
    #   foo.message_type
    #   >> 1
    #
    #   foo.message_type_code
    #   >> #<ONIX::Code:.......>
    #
    #   foo.message_type_code.key
    #   >> 1
    #
    #   foo.message_type_code.to_s
    #   >> "01"
    #
    #   foo.message_type_code.value
    #   >> "Early notification"
    #
    #
    def self.onix_code_from_list(name, tag_name, options = {})
      unless list_number = options.delete(:list)
        raise ONIX::CodeListNotSpecified
      end
      prep = lambda { |value| ONIX::Code.new(list_number, value, options) }
      options = options.merge(:from => tag_name)
      xml_accessor("#{name}_code", options, &prep)

      define_method(name) do
        send("#{name}_code").key
      end

      define_method("#{name}=") do |val|
        val = prep.call(val)  unless val.kind_of?(ONIX::Code)
        send("#{name}_code=", val)
      end
    end

    # Like onix_code_from_list, but for an array of codes.
    #
    # Required:
    #
    #   :list - integer referring to an ONIX Code List
    #
    # One important caveat: when assigning to this accessor, you must
    # pass in the complete array -- if you assign an array that you later
    # push or shift items into, you might get unexpected results.
    #
    # Similar to onix_code_from_list, this creates a special accessor for the
    # Code objects at (#x_codes/#x_codes=). For example:
    #
    #   class Bar < ONIX::Element
    #     onix_codes_from_list(:identifiers, "Identifier", :list => 5)
    #   end
    #
    #   bar = Bar.new
    #
    #   bar.identifiers = [1, 5, 13]
    #
    #   bar.identifiers_codes.collect { |ids| ids.value }
    #   >> ["Proprietary", "ISMN-10", "LLCN"]
    #
    def self.onix_codes_from_list(name, tag_name, options = {})
      unless list_number = options.delete(:list)
        raise ONIX::CodeListNotSpecified
      end
      prep = lambda { |values|
        [values].flatten.collect do |data|
          ONIX::Code.new(list_number, data, options)
        end
      }
      options = options.merge(:from => tag_name, :as => [])
      xml_accessor("#{name}_codes", options, &prep)

      define_method(name) do
        codes = send("#{name}_codes")
        codes ? codes.collect { |cd| cd.key } : nil
      end

      # FIXME: Hmm, adding to array? what happens with push, etc?
      define_method("#{name}=") do |vals|
        vals = [vals].flatten.collect { |v|
          v.kind_of?(ONIX::Code) ? v : prep.call(v)
        }.flatten
        send("#{name}_codes=", vals)
      end
    end

  end


  class CodeListNotSpecified < ArgumentError
  end

end