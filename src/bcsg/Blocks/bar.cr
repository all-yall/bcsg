
class Bar < Block
  
  @@default_style = Bar.get_bar_resource("bar")
  
  def initialize(strings, bools, name, parent = nil, properties = nil)
    super
    @style = @@default_style
    if !@properties.nil?
      prop = @properties.as(XML::Node)
      if prop["style"]?
        @style = Bar.get_bar_resource(prop["style"])
      end
    end
  end

  def get_sprites 
    ret = [] of SF::Drawable
    start = @style[0].size[0] + @x 
    fin   = @width - (@style[2].size[0]) + @x
    
    img = SF::Sprite.new(@style[1])
    img.position = {start, @y}
    img.texture_rect = SF.int_rect(0, 0, fin - start, img.global_bounds.height.to_i)
    ret << img

    img = SF::Sprite.new(@style[0])
    img.position = {@x, @y}
    ret << img

    img = SF::Sprite.new(@style[2])
    img.position = {fin, @y}
    ret << img
    
    return ret
  end 

  def self.get_bar_resource(name : String) : Array(SF::Texture)
    ["left", "center", "right"].map do |str|
      texture = SF::Texture.from_file(self.get_resource(name + "/" + str + ".png"))
      texture.repeated = true
      texture
    end
  end
end
