# coding: utf-8

require 'spec_helper.rb'
require 'date'

describe "Cacofonix::APAProduct" do

  before(:each) do
    load_doc_and_root("product.xml")
    @product_node = @root
  end

  it "should provide read access to attributes" do
    @product = Cacofonix::Product.from_xml(@product_node.to_s)
    @apa     = Cacofonix::APAProduct.new(@product)

    @apa.record_reference.should eql("365-9780194351898")
    @apa.notification_type.should eql(3)
    @apa.product_form.should eql("BC")
    @apa.number_of_pages.should eql(100)
    @apa.bic_main_subject.should eql("EB")
    @apa.publishing_status.should eql(4)
    @apa.publication_date.should eql(Date.civil(1998,9,1))
    @apa.pack_quantity.should eql(12)
  end

  it "should provide write access to attributes" do
    apa = Cacofonix::APAProduct.new

    apa.notification_type = 3
    apa.to_xml.to_s.include?("<NotificationType>03</NotificationType>").should be true

    apa.record_reference = "365-9780194351898"
    apa.to_xml.to_s.include?("<RecordReference>365-9780194351898</RecordReference>").should be true

    apa.product_form = "BC"
    apa.to_xml.to_s.include?("<ProductForm>BC</ProductForm>").should be true

    apa.number_of_pages = 100
    apa.to_xml.to_s.include?("<NumberOfPages>100</NumberOfPages>").should be true

    apa.bic_main_subject = "EB"
    apa.to_xml.to_s.include?("<BICMainSubject>EB</BICMainSubject>").should be true

    apa.publishing_status = 4
    apa.to_xml.to_s.include?("<PublishingStatus>04</PublishingStatus>").should be true

    apa.publication_date = Date.civil(1998,9,1)
    apa.to_xml.to_s.include?("<PublicationDate>19980901</PublicationDate>").should be true

    apa.pack_quantity = 12
    apa.to_xml.to_s.include?("<PackQuantity>12</PackQuantity>").should be true
  end

end

describe Cacofonix::APAProduct, "series method" do
  it "should set the nested series value on the underlying product class" do
    apa = Cacofonix::APAProduct.new

    apa.series = "Harry Potter"
    apa.series.should eql("Harry Potter")
    apa.to_xml.to_s.include?("<TitleOfSeries>Harry Potter</TitleOfSeries>").should be true
  end
end

describe Cacofonix::APAProduct, "price method" do
  before(:each) do
    load_doc_and_root("usd.xml")
    @product_node = @root
  end

  it "should return the first price in the file, regardless of type" do
    @product = Cacofonix::Product.from_xml(@product_node.to_s)
    @apa     = Cacofonix::APAProduct.new(@product)

    @apa.price.should eql(BigDecimal("99.95"))
  end
end

describe Cacofonix::APAProduct, "rrp_exc_sales_tax method" do
  before(:each) do
    load_doc_and_root("usd.xml")
    @product_node = @root
  end

  it "should return the first price in the file of type 1" do
    @product = Cacofonix::Product.from_xml(@product_node.to_s)
    @apa     = Cacofonix::APAProduct.new(@product)

    @apa.rrp_exc_sales_tax.should eql(BigDecimal("99.95"))
  end
end
