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
              "panel"     => Panel,
              "button"    => Button,
              "block"     => Block,
              "selector"  => Select,
              "text"      => Text,
              "animation" => Animation
            }

  def initialize(@window : SF::RenderWindow, name)
    @strings = {} of String => String
    @bools   = {} of String => Bool
    @blocks  = {} of String => Block
    @file = XML.parse(File.open(name + ".xml"))
    @window_size = @window.size
    @block_types = @@default_block_types.dup
  end

  def key_input(key : String, down : Bool)
    @root.as(Block).input(key, down)
  end

  def mouse_click(x, y)
    @root.as(Block).mouse_click(x, y)
  end

  def mouse_release
    @root.as(Block).mouse_release
  end

  def draw
    if @window.size != @window_size
      @window_size = @window.size
      resize
    end
    @root.as(Block).draw @window
  end

  # add a new block type to the gui other than the dafaults.
  def register(block : Block.class)
      @block_types[block.to_s.downcase] = block
  end

  def get(node : XML::Node, parent_block : Block | Nil)
    # make the block
    node_type = node["type"]?
    the_class = (node_type.nil? ? Block : @block_types[node_type])
    block = the_class.new(@strings, @bools, node.name, parent_block, node)

    #give it any of the extra properties in the node if they exist
    if node["dims"]?
      block.dims = node["dims"]
    end
    if node["handle"]?
      block.handle = node["handle"]
    end

    # give it a spot in the blocks hash and return
    @blocks[block.name] = block
    return block
  end

  def create()
    @root = get(@file, nil)
    @root.as(Block).gui = self
    create(@root.as(Block), @file)
    resize
  end

  def resize()
    @root.as(Block).update_size(@window.size[0], @window.size[1])
  end

  def create(parent_block, parent_node)
    parent_node.children.each do |child_node|
      next if child_node.name == "text"
      child_block = get(child_node, parent_block)
      create(child_block, child_node)
      parent_block.children << child_block
    end
  end

  def to_s
    if @root.nil?
      return "*Uncreated*"
    else
      @root.to_s
    end
  end
end
