
class Panel < Block
  
  @textures : Array(SF::Texture)

  def initialize(strings, bools, name, parent = nil, properties = nil, gui = nil)
      super
      @textures = get_panel_textures("panel")
      if !@properties.nil?
        prop = @properties.as(XML::Node)
        if prop["style"]?
          set_textures(prop["style"])
        end
      end
  end
  
  def set_textures(path : String)
    @textures = get_panel_textures(path)
  end  

  def get_sprites
    get_panel_sprites(@textures)
  end
end
