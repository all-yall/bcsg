
class Panel < Block
  property style : Array(SF::Texture)
  @@default_style = Block.get_style("panel")

  def initialize(strings, bools, name, parent = nil, properties = nil)
      super
      @style = @@default_style
      @scale = 4
      if !@properties.nil?
        prop = @properties.as(XML::Node)
        if prop["style"]?
                @style = Block.get_style(prop["style"])
        end
        if prop["scale"]?
          @scale = prop["scale"].to_i
        end
      end
  end
    
  def get_sprites
    get_panel(@style)
  end
end
