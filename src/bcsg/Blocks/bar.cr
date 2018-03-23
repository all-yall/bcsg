
class Bar < Block
  @@default_style = Bar.get_bar_resource("bar_template")
  def initialize(strings, bools, name, parent = nil, properties = nil)
    super
    @style = @@default_style
    @scale = 4
    if !@properties.nil?
      prop = @properties.as(XML::Node)
      if prop["style"]?
        @style = Bar.get_bar_resource(prop["style"])
      end
      if prop["scale"]?
        @scale = prop["scale"].to_i
      end
    end
  end

  def draw
    start = @style[0].size[0]
    fin   = @width - @style[2].size[0]
    edge  = @style[1].size[0]
    img = SF::Sprite.new(@style[1])
    (0.. (start - fin ) / ).each do |x|

    end
  end

  def self.get_bar_resource(name : String) : Array(SF::Texture)
    ["left", "center", "right"].map do |str|
      next SF::Texture.from_file(self.get_resource(name + "/" + str + ".png"))
    end
  end
end
