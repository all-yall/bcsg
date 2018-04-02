
class Button_Text < Button 
  def initialize(strings, bools, name, parent = nil, properties = nil, gui = nil)
    super
    temp_bools   = {} of String => Bool
    temp_strings = {} of String => String
    @text = Text.new temp_strings, temp_bools, "label", nil, nil, get_gui
    @text.content = "sample"
    if !@properties.nil?
      prop = @properties.as(XML::Node)
      @text.content = prop.content
    end 
    @text.parent = self
    @text.dims = "50,35,100,60"
    @children << @text
  end 
end 
