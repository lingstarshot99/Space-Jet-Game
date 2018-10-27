require 'rubygems'
require 'gosu'
require './spacejet_ui.rb'
require './spacejet_sprites.rb'

SCREEN_HEIGHT = 600
SCREEN_WIDTH = 600
ANGLE = 0

module ZOrder
  BACKGROUND, OBJECT, PLAYER, UI = *0..3
end

class SpaceJetGame < Gosu::Window
  def initialize
    super SCREEN_WIDTH, SCREEN_HEIGHT
    self.caption = "Space Jet Game"
    create_sprites
    create_ui
  end

  def draw
    draw_ui
    draw_sprites
  end

  def update
    jet_handling
    ui_control
    entities_handling
    collision_handling
    entities_generation
  end

  def needs_cursor?
    true
  end

end

SpaceJetGame.new.show
