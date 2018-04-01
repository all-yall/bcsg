require "xml"
require "crsfml"
require "./Blocks/block"
require "./Blocks/*"

# code horses

class GUI 
  property strings, bools
  @block_types : Hash(String,Block.class)
  @root : Block | Nil
  @window_size : SF::Vector2(Int32)
  @@default_block_types = {
              "panel"       => Panel,
              "button"      => Button,
              "block"       => Block,
              "selector"    => Select,
              "text"        => Text,
              "button_icon" => Button_Icon,
              "button_text" => Button_Text 
            }

  def initialize(@window : SF::RenderWindow, name : String)
    @strings = {} of String => String
    @bools   = {} of String => Bool
    @blocks  = {} of String => Block
    @file = XML.parse(File.open(get_resource(name + ".xml")))
    @window_size = @window.size
    @block_types = @@default_block_types.dup
    @textures = {} of String => SF::Texture
    @fonts = {} of String => SF::Font
  end

  # call this when any key is pressed and you have a Block
  # that takes key input. none do by default, so you probaby
  # can ignore this one.
  def key_input(key : String, down : Bool)
    @root.as(Block).input(key, down)
  end

  # call this when the mouse is clicked
  def mouse_click(x, y)
    @root.as(Block).mouse_click(x, y)
  end

  # call this when the mouse is released.
  def mouse_release
    @root.as(Block).mouse_release
  end
 
  # returns the path to the given name of a resource
  def get_resource(name : String) 
    return "./resources/" + name 
  end 

  # this loads a texture and  then keeps it in a hash so that
  # future calls won't make a new instance, you are encouraged to
  # use this to prevent unececary usage of memory.
  def get_texture(name : String) : SF::Texture
    name = name.strip 
    # return it if it has been created before
    return @textures[name] if @textures.has_key?(name)
    
    # else make it, add it to the hash, and return it
    text = SF::Texture.from_file(get_resource(name))
    @textures[name] = text 
    return text
  end 

  # the same as get_texture, but for fonts.
  def get_font(name : String) : SF::Font
    name = name.strip 
    # return it if it has been created before
    return @fonts[name] if @fonts.has_key?(name)
    
    # else make it, add it to the hash, and return it
    text = SF::Font.from_file(get_resource(name))
    @fonts[name] = text 
    return text
  end 
  
  # draws the GUI to the window
  def draw : Nil
    if @window.size != @window_size
      @window_size = @window.size
      resize
    end
    @root.as(Block).draw @window
  end
 
  # update and return self or the next GUI 
  def tick : GUI 
    @root.as(Block).tick 
    if should_close
      return close 
    end  
    return self
  end
  
  # should return true when the window should close
  private def should_close : Bool 
    return false
  end
 
  # do all closing actions and return next GUI 
  # in implentation should not return self
  private def close : GUI
    return self
  end

  # add a new block type to the gui other than the defaults so
  # that when they appear in the XML file they will be parsed correctly.
  def register(block : Block.class)
      @block_types[block.to_s.downcase] = block
  end

  # makes a Block from a node and adds it to the parent_blocks
  # children if possible
  private def get(node : XML::Node, parent_block : Block | Nil)
    # make the block
    node_type = node["type"]?
      the_class = (node_type.nil? ? Block : @block_types[node_type.downcase.strip])
    block = the_class.new(@strings, @bools, node.name, parent_block, node)

    # give it a spot in the blocks hash and return
    @blocks[block.name] = block
    return block
  end

  # initializes the root node, call this after registering
  # any other non-default blocks you will use and before draw.
  def create : Nil
    @root = get(@file, nil)
    @root.as(Block).gui = self
    create(@root.as(Block), @file)
    resize
  end

  # updates the size of the GUI, is called automatically 
  # when window size changes
  private def resize : Nil
    @root.as(Block).update_size(@window.size[0], @window.size[1])
  end

  # the reccursive method that the non-private create wraps.
  private def create(parent_block, parent_node) : Nil
    parent_node.children.each do |child_node|
      next if child_node.name == "text"
      child_block = get(child_node, parent_block)
      create(child_block, child_node)
      parent_block.children << child_block
    end
  end
  
  # Mainly for debugging 
  def to_s
    if @root.nil?
      return "*Uncreated*"
    else
      @root.to_s
    end
  end
end
