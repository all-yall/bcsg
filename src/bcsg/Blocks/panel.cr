
class Panel < Block
  property style : SF::Texture
  @@default_style = SF::Texture.from_file(get_resource("window_template.png"))

  def initialize(strings, bools, name, parent = nil, properties = nil)
      super
      @style = @@default_style
      @scale = 4
      if !@properties.nil?
        prop = @properties.as(XML::Node)
        if prop["style"]?
          @style = SF::Texture.from_file(prop["style"])
        end
        if prop["scale"]?
          @scale = prop["scale"].to_i
        end
      end
  end

  def draw(window : SF::Window)
    draw_panel(window, @style, @scale)
    super
  end
end
