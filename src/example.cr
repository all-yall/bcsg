require "./bcsg.cr"


class Test < Block
end
window = SF::RenderWindow.new(SF::VideoMode.new(800, 600), "My window")

window.framerate_limit = 60

temp = GUI.new(window, "gui")
puts temp.to_s
temp.register(Test)
temp.create
puts temp.to_s

# run the program as long as the window is open
while window.open?
  # check all the window's events that were triggered since the last iteration of the loop
  while event = window.poll_event

    if event.is_a? SF::Event::MouseButtonPressed
      temp.mouse_click(event.x, event.y)
    elsif event.is_a? SF::Event::MouseButtonReleased
      temp.mouse_release
      # "close requested" event: we close the window
    elsif event.is_a? SF::Event::Closed
      window.close
    elsif event.is_a? SF::Event::Resized
      visible_area = SF.float_rect(0, 0, event.width, event.height)
      window.view = SF::View.new(visible_area)
    end
  end

  # clear the window with black color
  window.clear(SF::Color::Black)

  # draw everything here...
  temp.draw

  # end the current frame
  window.display
end
