# coding: utf-8

class Cacofonix::SeriesIdentifier < Cacofonix::Identifier
  xml_name "SeriesIdentifier"
  onix_code_from_list :series_id_type, "SeriesIDType", :list => 13
end
