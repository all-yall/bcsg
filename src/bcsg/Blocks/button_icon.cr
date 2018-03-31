
class Button_Icon < Button
  
  def initialize(strings, bools, name, parent = nil, properties = nil, gui = nil)
    super
    # yes, it would make more sense singular, but i want to 
    # reduce the memory footprint by garbage collecting
    # Button's versions.
    @textures_pressed = [get_gui.get_texture("button_icon/pressed.png")] 
    @textures_normal  = [get_gui.get_texture("button_icon/normal.png")] 
    @sprites_pressed = [get_sprite(@textures_pressed[0], true, false)] of SF::Drawable   
    @sprites_normal  = [get_sprite(@textures_normal[0], true, false)] of SF::Drawable 
  end

  def get_sprites 
    @sprites_pressed[0] = get_sprite(@textures_pressed[0], true, false)   
    @sprites_normal[0]  = get_sprite(@textures_normal[0], true, false)   
    return [] of SF::Drawable 
  end 
end
