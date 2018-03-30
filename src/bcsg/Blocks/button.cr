
class Button < Block

  @bools : Hash(String,Bool)

  @style_normal : Array(SF::Texture)
  @style_pressed : Array(SF::Texture)

  @sprites_pressed : Array(SF::Drawable)
  @sprites_normal  : Array(SF::Drawable)
  
  def initialize(strings, bools, name, parent = nil, properties = nil)
    super
    @bools = bools
    @bools[@name] = false
    @style_normal  = Block.get_style("button_template/normal")
    @style_pressed = Block.get_style("button_template/pressed")
    @sprites_pressed = get_panel(@style_pressed)   
    @sprites_normal  = get_panel(@style_normal)   
  end

  def get_bool
    @bools[@name]
  end
   
  def get_sprites 
    @sprites_pressed = get_panel(@style_pressed)   
    @sprites_normal  = get_panel(@style_normal)   
    return super 
  end 

  def draw(window : SF::Window)
    @sprites = @clicked ? @sprites_pressed : @sprites_normal
    super
  end

  def mouse_click(x, y)
    return false if !in_bounds?(x, y)
    @clicked = true
    @bools[@name] = true
    return true
  end

  def mouse_release()
    @clicked = false
  end
end
