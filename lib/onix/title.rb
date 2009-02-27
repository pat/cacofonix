module ONIX
  class Title
    include ROXML 

    xml_name "Title"

    xml_accessor :title_type, :from => "TitleType", :as => Fixnum, :to_xml => ONIX::Formatters.two_digit
    xml_accessor :title_text, :from => "TitleText"
    xml_accessor :subtitle,   :from => "Subtitle"

  end
end
