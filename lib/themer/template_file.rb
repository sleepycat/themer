module EftPlus
  class TemplateFile

    require 'rubygems'
    require 'nokogiri'
  
    attr_accessor :filename

    def initialize file = nil
      self.read_file file if file
    end

    def read_file file
      @file_path = file
      @file = Nokogiri::HTML(open(file)) if File.exists? file
      generate_methods(@file)
      @file
    end

    def parse html
      @file = Nokogiri::HTML::Document.parse html
      generate_methods(@file)
      @file
    end

    def extract_class_to_partial class_name
      fragments = @file.xpath("//*[@class='#{class_name}']")
      partial_name = "_#{class_name}.html.erb"
      fragments.each_with_index do |fragment, i|
        if i == 0
          content_to_file fragment.path.to_s, File.join((File.split(@file_path)[-2]), partial_name)
          replace_tag fragment.path.to_s, "\r\n<%= render :partial => '#{class_name}' %>\r\n"
        else
          destroy fragment.path
        end
      end
    end
  
    def destroy xpath
      fragment = @file.at_xpath(xpath)
      fragment.unlink
    end

    def content_to_file xpath, file_path
      fragment = @file.at_xpath("#{xpath}")
      File.open(file_path, 'w+'){|f| f << fragment.to_html}
    end

    def replace_content tag, replacement_string
      replacement = Nokogiri::XML::CDATA.new(@file, replacement_string)
      target_tag = @file.at_xpath(tag)
      if target_tag
        target_tag.children.unlink
        replacement.parent= target_tag
      else
        puts "Couldn't find a tag matching #{tag}."
      end
    end

    def append_to tag, additional_text
      target = @file.at_xpath tag
      replacement_tag = Nokogiri::XML::CDATA.new(@file, additional_text)
      targets_last_child =  target.last_element_child
      targets_last_child.add_next_sibling(replacement_tag)
    end

    def replace_tag tag, replacement_string
      replacement_tag = Nokogiri::XML::CDATA.new(@file, replacement_string)
      target_tag = @file.at_xpath(tag)
      if target_tag
        target_tag.swap(replacement_tag)
      else
        puts "Couldn't find a tag matching #{tag}."
      end
    end

    def save
      if File.open(@file_path, 'w+'){|f| f << @file.to_html}
        true
      end
    end

    private

    def generate_methods file
      elements = file.xpath("//head", "//title", "//body", "//*[@id]")

      elements.each do |element|
        TemplateFile.define_getter(element)
        TemplateFile.define_setter(element)
      end
    end


    def method_missing method, *args
      puts "This file doesn't seem to have a #{method}"
    end

    def self.define_getter(ele)
      if ele.has_attribute? "id"
        define_method(ele[:id].to_sym) do
          @file.at_xpath("//*[@id='#{ele[:id]}']").children.to_html
        end
      else
        define_method(("#{ele.name}").to_sym) do
          @file.at_xpath("//#{ele.name}").children.to_html
        end
      end
    end
  
    def self.define_setter(ele)
      if ele.has_attribute? "id"
        define_method(("#{ele[:id]}=").to_sym) do |x|
          replace_content("//*[@id='#{ele[:id]}']", x)
        end
      else
        define_method(("#{ele.name}=").to_sym) do |x|
          replace_content("//#{ele.path}", x)
        end
      end
    end
  end
end