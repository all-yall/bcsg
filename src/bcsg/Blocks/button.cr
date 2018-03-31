
class Button < Block

  @bools : Hash(String,Bool)

  @textures_normal : Array(SF::Texture)
  @textures_pressed : Array(SF::Texture)

  @sprites_pressed : Array(SF::Drawable)
  @sprites_normal  : Array(SF::Drawable)
  
  def initialize(strings, bools, name, parent = nil, properties = nil, gui = nil)
    super
    @bools = bools
    @bools[@name] = false
    @textures_normal  = get_panel_textures("button_template/normal")
    @textures_pressed = get_panel_textures("button_template/pressed")
    @sprites_pressed  = get_panel_sprites(@textures_pressed)   
    @sprites_normal   = get_panel_sprites(@textures_normal)   
  end

  def get_bool
    @bools[@name]
  end
   
  def get_sprites 
    @sprites_pressed = get_panel_sprites(@textures_pressed)   
    @sprites_normal  = get_panel_sprites(@textures_normal)   
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
