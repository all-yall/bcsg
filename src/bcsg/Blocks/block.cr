class Block
  property parent : Block | Nil,
  children : Array(Block),
  x : Int32,
  y : Int32,
  width : Int32,
  height : Int32,
  name : String,
  dims : String,
  handle : String,
  properties : XML::Node | Nil,
  gui : GUI | Nil
    
  @sprites : Array(SF::Drawable)
  
  def initialize(strings, bools, @name, @parent = nil, @properties = nil, @gui = nil)
    @gui = @parent.as(Block).gui if !@parent.nil?
    @dims = "50,50,100,100"
    @handle = "50,50"
    @x = 0
    @y = 0
    @width = 100
    @height = 100
    if !@properties.nil? 
      prop = @properties.as(XML::Node)
      @dims = prop["dims"] if prop["dims"]?
      @handle = prop["handle"] if prop["handle"]?
    end
    @sprites = [] of SF::Drawable
    set_size
    @children = [] of Block
  end

  def update_size(width, height)
    @width = width
    @height = height
    update_size
  end

  def update_size
    set_size
    @sprites = get_sprites
    children.each do |child|
      child.update_size
    end
  end

  # get an array of te sprites that will be displayed
  def get_sprites : Array(SF::Drawable)
    [] of SF::Drawable
  end 

  def set_size
    if !@parent.nil?
      par = @parent.as(Block)
      perc_x, perc_y, perc_w, perc_h = @dims.split(",")
      hand_x, hand_y = @handle.split(",")

      get_length =
      -> (str : String, default : Int32, other : Int32) do
        if str[-1] == 'o'
          perc = str[0, str.size - 1].to_i
          return (other * perc) / 100
        else
          perc = str.to_i
          return (default * perc) / 100
        end
      end

      @width  = get_length.call(perc_w, par.width, par.height)
      @height = get_length.call(perc_h, par.height, par.width)

      x_offs  = get_length.call(hand_x, @width, @height)
      y_offs  = get_length.call(hand_y, @height, @width)

      @x      = get_length.call(perc_x, par.width, par.height) + par.x - x_offs
      @y      = get_length.call(perc_y, par.height, par.width) + par.y - y_offs

    end
  end

  def mouse_click(x, y)
    return if !in_bounds?(x, y)
    children.each do |child|
      child.mouse_click(x, y)
    end
  end

  def mouse_release()
    children.each do |child|
      child.mouse_release()
    end
  end

  def in_bounds?(x, y) : Bool
    (0 <= (x - @x) <= @width) &&
    (0 <= (y - @y) <= @height)
  end

  def key_input(key, down) : Bool
    ret = false
    children.while do |child|
      ret ||= child.key_input(key, down)
      !ret
    end
    return ret
  end

  # draws to the provided screen
  def draw(window : SF::Window)
    @sprites.each do |sprite| window.draw sprite end 
    @children.each do |child|  child.draw window  end
  end
  
  # updates things
  def tick 
    @children.each do |child| child.tick end
  end 

  # for debugging purposes
  def draw_rectangle
    rect = SF::RectangleShape.new
    rect.size = {@width, @height}
    rect.position = {@x, @y}
    rect.outline_color = SF::Color::Red
    rect.outline_thickness = 2
    window.draw rect
  end

  def get_panel_sprites(textures : Array(SF::Texture))
    ret = [] of SF::Drawable
    style = textures.map {|texture| SF::Sprite.new(texture)}

    get_height = -> (sprite : SF::Sprite) do
        (sprite.texture.as(SF::Texture).size[1]).to_i
    end

    get_width = -> (sprite : SF::Sprite) do
        (sprite.texture.as(SF::Texture).size[0]).to_i
    end
    
    set_bounds = -> (sprite : SF::Sprite, x : Int32, y : Int32, width : Int32, height : Int32) do 
       sprite.position = {x, y}
       sprite.texture_rect = SF.int_rect(0, 0, width , height ) 
       width > 0 && height > 0
    end 

    # center
    sprite = style[4]
    if set_bounds.call(sprite,
        @x + get_width.call(style[3]),
        @y + get_height.call(style[1]),
        @width  - get_width.call(style[5]) - get_width.call(style[3]),
        @height - get_height.call(style[7]) - get_height.call(style[1]))
    ret << sprite
    end

    # left edge
    sprite = style[3]
    if set_bounds.call(sprite,
        @x,
        @y + get_height.call(style[0]),
        get_width.call(sprite),
        (@height - get_height.call(style[0]) - get_height.call(style[6])))
    ret << sprite
    end 

    # upper edge
    sprite = style[1]
    if set_bounds.call(sprite,
        @x + get_width.call(style[0]),
        @y,
        @width - get_width.call(style[2]) - get_width.call(style[0]),
        get_height.call(sprite))
    ret << sprite
    end 

    # lower edge
    sprite = style[7]
    if set_bounds.call(sprite,
        @x + get_width.call(style[0]),
        @y + @height - get_height.call(sprite),
        @width - get_width.call(style[2]) - get_width.call(style[0]),
        get_height.call(sprite))
    ret << sprite
    end 

    # right edge
    sprite = style[5]
    if set_bounds.call(sprite,
        @x + @width - get_width.call(sprite),
        @y + get_height.call(style[2]),
        get_width.call(sprite),
        @height - get_height.call(style[2]) - get_height.call(style[8]))
    ret << sprite
    end 
    
    # top left corner
    sprite = style[0]
    if set_bounds.call(sprite,
        @x,
        @y,
        get_width.call(sprite),
        get_height.call(sprite))
    ret << sprite 
    end
    
    # top right corner
    sprite = style[2]
    if set_bounds.call(sprite,
        @x + @width - get_width.call(sprite),
        @y,
        get_width.call(sprite),
        get_height.call(sprite))
    ret << sprite 
    end
    
    # bottom left corner
    sprite = style[6]
    if set_bounds.call(sprite,
        @x,
        @y + @height - get_height.call(sprite),
        get_width.call(sprite),
        get_height.call(sprite))
    ret << sprite 
    end
    
    # bottom right corner
    sprite = style[8]
    if set_bounds.call(sprite,
        @x + @width - get_width.call(sprite),
        @y + @height - get_height.call(sprite),
        get_width.call(sprite),
        get_height.call(sprite))
    ret << sprite 
    end

    return ret
  end

  # given the path to a style file relative to the resource
  # folder, this will return an array of the textures contained
  # in it
  def get_panel_textures(filename : String) : Array(SF::Texture)
    ["tl_corner", "t_edge", "tr_corner",
     "l_edge",    "center", "r_edge",
     "bl_corner", "b_edge", "br_corner"].map do |part|
       texture = get_gui.get_texture(filename + "/" + part + ".png")
       texture.repeated = true 
       texture 
     end
  end

  # booleans are to scale the texture
  # with respect to their dimension
  # true for both isn't suggested
  # as it will stretch or squeeze the texture.
  def get_sprite(text : SF::Texture, width : Bool, height : Bool)
    w_scale = @width.to_f  / text.size[0]
    h_scale = @height.to_f / text.size[1]
    sprite = SF::Sprite.new(text)
    sprite.scale = if width && height
                     {w_scale, h_scale}
                   elsif width 
                     {w_scale, w_scale}
                   elsif height 
                     {h_scale, h_scale}
                   else 
                     {1, 1} 
                   end 
    sprite.position = {@x,@y}
    return sprite
  end

  # convenience function to save keystrokes
  def get_gui 
    @gui.as(GUI)
  end 

  def to_s
    to_s("")
  end

  def to_s(prefix)
    ret = prefix + "|#{self.class} |"
    prefix = " " * (ret.size - 1)
    children.each do |child|
      ret += "\n" + child.to_s(prefix)
    end
    return ret
  end
end
