# coding: utf-8

class Cacofonix::Title < Cacofonix::Element
  xml_name "Title"
  onix_code_from_list :title_type, "TitleType", :list => 15
  xml_accessor :abbreviated_length, :from => "AbbreviatedLength", :as => Integer
  xml_accessor :title_text, :from => "TitleText"
  xml_accessor :title_prefix, :from => "TitlePrefix"
  xml_accessor :title_without_prefix, :from => "TitleWithoutPrefix"
  xml_accessor :subtitle,   :from => "Subtitle"
end
