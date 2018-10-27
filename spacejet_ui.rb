def create_ui
  @bullet1 = Gosu::Image.new("media/bullet1.png", :tileable => true)
  @portal = Gosu::Image.new("media/portal.png", :tileable => true)
  @background_image = Gosu::Image.new("media/space.png", :tileable => true)
  @dashboard = Gosu::Font.new(20)
  @inventory = Gosu::Font.new(20)
  @show_inventory = false
end

def draw_ui
  @background_image.draw(0, 0 , ZOrder::BACKGROUND)
  @dashboard.draw("Score: #{@jet.score} Lives: #{@jet.lives}", 10, 10, ZOrder::UI, 1.0, 1.0, Gosu::Color::GREEN)
  if @show_inventory == true
    @bullet1.draw(10, 98, ZOrder::UI)
    @inventory.draw("x#{@jet.ammo}", 35, 100, ZOrder::UI, 1.0, 1.0, Gosu::Color::CYAN)
    @portal.draw(10, 130, ZOrder::UI)
    if @jet.warp == true
      @inventory.draw("Available", 35, 130, ZOrder::UI, 1.0, 1.0, Gosu::Color::CYAN)
    else
      @inventory.draw("Not available",35, 130, ZOrder::UI, 1.0, 1.0, Gosu::Color::CYAN)
    end
  end
end

def ui_control
  if Gosu.button_down?(Gosu::KB_ESCAPE)
    close
  end
  if Gosu.button_down?(Gosu::KB_Z)
    if @show_inventory == false
      @show_inventory = true
    end
  end
  if Gosu.button_down?(Gosu::KB_X)
    if @show_inventory == true
      @show_inventory = false
    end
  end
end
