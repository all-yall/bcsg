
class Bar < Block
 
  @textures : Array(SF::Texture) 
  def initialize(strings, bools, name, parent = nil, properties = nil, gui = nil)
    super
    @textures = get_bar_textures("bar")
    if !@properties.nil?
      prop = @properties.as(XML::Node)
      if prop["style"]?
        @textures = get_bar_textures(prop["style"])
      end
    end
  end

  def get_sprites 
    ret = [] of SF::Drawable
    start = @textures[0].size[0] + @x 
    fin   = @width - (@textures[2].size[0]) + @x
    
    img = SF::Sprite.new(@textures[1])
    img.position = {start, @y}
    img.texture_rect = SF.int_rect(0, 0, fin - start, img.global_bounds.height.to_i)
    ret << img

    img = SF::Sprite.new(@textures[0])
    img.position = {@x, @y}
    ret << img

    img = SF::Sprite.new(@textures[2])
    img.position = {fin, @y}
    ret << img
    
    return ret
  end 

  def get_bar_textures(name : String) : Array(SF::Texture)
    ["left", "center", "right"].map do |str|
      texture = get_gui.get_texture(name + "/" + str + ".png")
      texture.repeated = true
      texture
    end
  end
end
