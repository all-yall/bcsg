
class Button_Icon < Button
  @@default_bi_style_normal = [SF::Texture.from_file(get_resource("button_icon/normal.png"))]
  @@default_bi_style_pressed  = [SF::Texture.from_file(get_resource("button_icon/pressed.png"))] 
  
  def initialize(strings, bools, name, parent = nil, properties = nil)
    super
    @style_pressed = @@default_bi_style_pressed 
    @style_normal  = @@default_bi_style_normal 
    @sprites_pressed = [get_sprite(@style_pressed[0], true, false)] of SF::Drawable   
    @sprites_normal  = [get_sprite(@style_normal[0], true, false)] of SF::Drawable 
  end

  def get_sprites 
    @sprites_pressed[0] = get_sprite(@style_pressed[0], true, false)   
    @sprites_normal[0]  = get_sprite(@style_normal[0], true, false)   
    return [] of SF::Drawable 
  end 
end
