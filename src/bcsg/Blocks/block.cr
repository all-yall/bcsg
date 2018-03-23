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
    "./recources/" + recource
  end

  def draw_panel(window : SF::Window, style : SF::Texture, scale : Number)
    edge = style.size[0] / 3
    length = edge * scale
    sprite = SF::Sprite.new(style)
    sprite.scale = {scale.to_f, scale.to_f}

    # center fill
    sprite.texture_rect = SF.int_rect(edge,edge,edge,edge)
    (1...(@width/length)).each do |x|
      (1...(@height/length)).each do |y|
        sprite.position = {@x + x * length, @y + y * length}
        window.draw sprite
      end
    end

    # upper edge
    sprite.texture_rect = SF.int_rect(edge,0,edge,edge)
    (1...(@width/length)).each do |x|
      sprite.position = {@x + x * length, @y}
      window.draw sprite
    end

    # lower edge
    sprite.texture_rect = SF.int_rect(edge,edge*2,edge,edge)
    (1...(@width/length)).each do |x|
      sprite.position = {@x + x * length, @y + @height - length}
      window.draw sprite
    end

    # left edge
    sprite.texture_rect = SF.int_rect(0,edge,edge,edge)
    (1...(@height/length)).each do |y|
      sprite.position = {@x, @y + y * length}
      window.draw sprite
    end

    # right edge
    sprite.texture_rect = SF.int_rect(edge*2,edge,edge,edge)
    (1...(@height/length)).each do |y|
      sprite.position = {@x + @width - length, @y + y * length}
      window.draw sprite
    end

    #corners
    sprite.texture_rect = SF.int_rect(0,0,edge,edge)
    sprite.position = {@x, @y}
    window.draw sprite

    sprite.texture_rect = SF.int_rect(edge*2,0,edge,edge)
    sprite.position = {@x + @width - length, @y}
    window.draw sprite

    sprite.texture_rect = SF.int_rect(0,edge*2,edge,edge)
    sprite.position = {@x, @y + @height - length}
    window.draw sprite

    sprite.texture_rect = SF.int_rect(edge * 2, edge * 2,edge,edge)
    sprite.position = {@x + @width - length, @y + @height - length}
    window.draw sprite
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
