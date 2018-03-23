
class Button < Block

  @bools : Hash(String,Bool)

  def initialize(strings, bools, name, parent = nil, properties = nil)
    super
    @bools = bools
    @bools[@name] = false
  end

  def get_bool
    @bools[@name]
  end

  def draw(window : SF::Window)
    rect = SF::RectangleShape.new
    rect.size = {@width, @height}
    rect.position = {@x, @y}
    rect.outline_color = SF::Color::Red
    rect.fill_color = @clicked ? SF::Color::Black : SF::Color::White
    rect.outline_thickness = 3
    window.draw rect
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
