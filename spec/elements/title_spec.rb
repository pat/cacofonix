# coding: utf-8

require 'spec_helper.rb'

describe Cacofonix::Title do

  before(:each) do
    load_doc_and_root("title.xml")
  end

  it "should correctly convert to a string" do
    t = Cacofonix::Title.from_xml(@root.to_s)
    t.to_xml.to_s[0,7].should eql("<Title>")
  end

  it "should provide read access to first level attributes" do
    t = Cacofonix::Title.from_xml(@root.to_s)
    t.title_type.should eql(1)
    t.title_text.should eql("Good Grief")
    t.subtitle.should   eql("A Constructive Approach to the Problem of Loss")
  end

  it "should provide write access to first level attributes" do
    t = Cacofonix::Title.new

    t.title_type = 1
    t.to_xml.to_s.include?("<TitleType>01</TitleType>").should be true

    t.title_text = "Good Grief"
    t.to_xml.to_s.include?("<TitleText>Good Grief</TitleText>").should be true

    t.subtitle = "Blah"
    t.to_xml.to_s.include?("<Subtitle>Blah</Subtitle>").should be true

  end

end

