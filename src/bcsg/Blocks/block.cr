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


  def initialize(strings, bools, @name, @parent = nil, @properties = nil)
    @gui = @parent.as(Block).gui if !@parent.nil?
    @dims = "50,50,100,100"
    @handle = "50,50"
    @x = 0
    @y = 0
    @width = 100
    @height = 100
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
    children.each do |child|
      child.update_size
    end
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

  def draw(window : SF::Window)
    children.each do |child| child.draw window end
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

  def self.get_resource(recource : String)
    "./resources/" + recource
  end

  def draw_panel(window : SF::Window, textures : Array(SF::Texture))
    
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
    window.draw sprite
    end

    # left edge
    sprite = style[3]
    if set_bounds.call(sprite,
        @x,
        @y + get_height.call(style[0]),
        get_width.call(sprite),
        (@height - get_height.call(style[0]) - get_height.call(style[6])))
    window.draw sprite
    end 

    # upper edge
    sprite = style[1]
    if set_bounds.call(sprite,
        @x + get_width.call(style[0]),
        @y,
        @width - get_width.call(style[2]) - get_width.call(style[0]),
        get_height.call(sprite))
    window.draw sprite
    end 

    # lower edge
    sprite = style[7]
    if set_bounds.call(sprite,
        @x + get_width.call(style[0]),
        @y + @height - get_height.call(sprite),
        @width - get_width.call(style[2]) - get_width.call(style[0]),
        get_height.call(sprite))
    window.draw sprite
    end 

    # right edge
    sprite = style[5]
    if set_bounds.call(sprite,
        @x + @width - get_width.call(sprite),
        @y + get_height.call(style[2]),
        get_width.call(sprite),
        @height - get_height.call(style[2]) - get_height.call(style[8]))
    window.draw sprite
    end 
    
    # top left corner
    sprite = style[0]
    if set_bounds.call(sprite,
        @x,
        @y,
        get_width.call(sprite),
        get_height.call(sprite))
        window.draw sprite 
    end
    
    # top right corner
    sprite = style[2]
    if set_bounds.call(sprite,
        @x + @width - get_width.call(sprite),
        @y,
        get_width.call(sprite),
        get_height.call(sprite))
        window.draw sprite 
    end
    
    # bottom left corner
    sprite = style[6]
    if set_bounds.call(sprite,
        @x,
        @y + @height - get_height.call(sprite),
        get_width.call(sprite),
        get_height.call(sprite))
        window.draw sprite 
    end
    
    # bottom right corner
    sprite = style[8]
    if set_bounds.call(sprite,
        @x + @width - get_width.call(sprite),
        @y + @height - get_height.call(sprite),
        get_width.call(sprite),
        get_height.call(sprite))
        window.draw sprite 
    end
  end

  def self.get_style(filename) : Array(SF::Texture)
    resource = get_resource(filename) + "/"
    ["tl_corner", "t_edge", "tr_corner",
     "l_edge",    "center", "r_edge",
     "bl_corner", "b_edge", "br_corner"].map do |part|
       texture = SF::Texture.from_file(resource + part + ".png")
       texture.repeated = true 
       texture 
     end
  end

  # booleans are to scale the texture
  # with respect to their dimension
  # true for both isn't suggested
  # as it will stretch or squeeze the texture.
  def draw_sprite(text : Texture, width : Boolean, height : Boolean)
    w_scale = -1
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
