
class Jet
  attr_accessor :score, :lives, :x, :y, :VEL, :image, :bang, :no_ammo, :plus_score, :minus_live, :itemize, :ammo, :warp, :explode

  def initialize(x, y)
    @image = Gosu::Image.new("media/starfighter.bmp")
    @bang = Gosu::Sample.new("media/bang.wav")
    @no_ammo = Gosu::Sample.new("media/no_ammo.wav")
    @minus_live = Gosu::Sample.new("media/damage.wav")
    @plus_score = Gosu::Sample.new("media/coin.wav")
    @itemize = Gosu::Sample.new("media/item.wav")

    @VEL = 3
    @x = x
    @y = y
    @score = 0
    @lives = 3
    @ammo = 20
    @warp = true
  end
end

class Bullet
  attr_accessor :x, :y, :vel, :image

  def initialize(x, y)
    @image = Gosu::Image.new("media/bullet1.png")
    @x = x
    @y = y
    @vel = 2
  end
end

class Alien

  attr_accessor :x, :y, :vel, :image

  def initialize
    @x = rand * SCREEN_WIDTH
    @y = 10

    @image = Gosu::Image.new("media/alien1.png")
    @vel = rand(2 .. 6)
  end
end

class Star

  attr_accessor :x, :y, :type, :image, :vel

  def initialize(image, type)
    @type = type
    @image = Gosu::Image.new(image)
    @vel = rand(1 .. 5)

    @y = 10
    @x = rand * SCREEN_WIDTH
  end
end

class Power
  attr_accessor :x, :y, :image, :type

  def initialize(image, type)
    @x = rand(0.1 .. 0.9) * SCREEN_WIDTH
    @y = rand(0.1 .. 0.9) * SCREEN_HEIGHT
    @image = Gosu::Image.new(image)
    @type = type
  end
end

def click(mouse_x, mouse_y)
  if @jet.warp == true
    if (mouse_x < SCREEN_WIDTH) && (mouse_y < SCREEN_HEIGHT)
      @jet.x = mouse_x
      @jet.y = mouse_y
    end
    @jet.warp = false
  end
end

def create_sprites
  @stars = Array.new
  @aliens = Array.new
  @bullets = Array.new
  @powerups = Array.new
  @jet = Jet.new(SCREEN_WIDTH/2, SCREEN_HEIGHT - 50)
end

def draw_sprites
  def draw_object(object, z)
    object.image.draw_rot(object.x, object.y, z, ANGLE)
  end
  def draw_for_array(array)
    array.each { |object|
      draw_object(object, ZOrder::OBJECT)
    }
  end
  draw_object(@jet, ZOrder::PLAYER)
  draw_for_array(@stars)
  draw_for_array(@aliens)
  draw_for_array(@bullets)
  draw_for_array(@powerups)
  # @stars.each { |star|
  #   draw_object(star, ZOrder::OBJECT)
  # }
  # @aliens.each { |alien|
  #   draw_object(alien, ZOrder::OBJECT)
  # }
  # @bullets.each { |bullet|
  #   draw_object(bullet, ZOrder::OBJECT)
  # }
  # @powerups.each { |power|
  #   draw_object(power, ZOrder::OBJECT)
  # }
end

def jet_handling
  def jet_right(jet)
    if jet.x < SCREEN_WIDTH - 30
      jet.x += jet.VEL
      puts('Turn righty')
    end
  end
  def jet_left(jet)
    if jet.x > 30
      jet.x -= jet.VEL
      puts('Turn lefty')
    end
  end
  def jet_up(jet)
    if jet.y > 30
      jet.y -= jet.VEL
      puts('Straight ahead')
    end
  end
  def jet_down(jet)
    if jet.y < SCREEN_WIDTH - 30
      jet.y += jet.VEL
      puts('Hold back')
    end
  end

  if Gosu.button_down?(Gosu::KB_LEFT)
    jet_left(@jet)
  end
  if Gosu.button_down?(Gosu::KB_RIGHT)
    jet_right(@jet)
  end
  if Gosu.button_down?(Gosu::KB_DOWN)
    jet_down(@jet)
  end
  if Gosu.button_down?(Gosu::KB_UP)
    jet_up(@jet)
  end
  if Gosu.button_down?(Gosu::MS_RIGHT)
    click(mouse_x, mouse_y)
  end
  if Gosu.button_down?(Gosu::KB_SPACE)
    if Gosu.milliseconds % 4 == 0 && @jet.ammo > 0
      @jet.bang.play
      @bullets.push(Bullet.new(@jet.x, @jet.y))
      @jet.ammo -= 1
    elsif @jet.ammo < 1
      @jet.no_ammo.play
    end
  end

end

def entities_handling
  def remove_off_screen(array)
    array.reject! do |object|
      if object.y > SCREEN_HEIGHT
        true
      else
        false
      end
    end
  end
  def move(object)
    object.y += object.vel
  end
  def shoot_bullet(bullet)
    bullet.y -= bullet.vel
  end

  @bullets.each { |bullet|
    shoot_bullet(bullet)
  }

  @stars.each { |star|
    move(star)
  }

  @aliens.each { |alien|
    move(alien)
  }

  self.remove_off_screen(@stars)
  self.remove_off_screen(@aliens)
  self.remove_off_screen(@bullets)
end

def collision_handling
  def kill_aliens(bullet, aliens)
    aliens.reject! do |alien|
      if Gosu.distance(bullet.x, bullet.y, alien.x, alien.y) < 40
        true
        bullet.y = 0
        bullet.x = SCREEN_WIDTH
      else
        false
      end
    end
  end

  def hit_alien(jet, aliens)
    aliens.reject! do |alien|
      if Gosu.distance(jet.x, jet.y, alien.x, alien.y) < 50
        jet.lives -= 1
        jet.minus_live.play
        true
      else
        false
      end
    end
  end

  def collect_powerups(jet, all_powerups)
    all_powerups.reject! do |power|
      if Gosu.distance(jet.x, jet.y, power.x, power.y) < 35
        case power.type
        when :health
          jet.lives += 1
        when :crate
          jet.ammo += 10
        when :portal
          jet.x = rand * SCREEN_WIDTH
          jet.y = rand * SCREEN_HEIGHT
          jet.warp = true
        end
        jet.itemize.play
        true
      else
        false
      end
    end
  end

  def collect_star(jet, all_stars)
    all_stars.reject! do |star|
      if Gosu.distance(jet.x, jet.y, star.x, star.y) < 50
        case star.type
        when :star1
          jet.score += 1
        when :star2
          jet.score += 2
        when :star3
          jet.score += 3
        end
        jet.plus_score.play
        true
      else
        false
      end
    end
  end

  collect_powerups(@jet, @powerups)
  collect_star(@jet, @stars)
  hit_alien(@jet, @aliens)
  @bullets.each { |bullet|
    kill_aliens(bullet, @aliens)
  }
end

def entities_generation
  def generate_star
    case rand(3)
    when 0
      Star.new("media/star1.png", :star1)
    when 1
      Star.new("media/star2.png", :star2)
    when 2
      Star.new("media/star3.png", :star3)
    end
  end
  def generate_powerups
    case rand(3)
    when 0
      Power.new("media/health.png", :health)
    when 1
      Power.new("media/crate.png", :crate)
    when 2
      Power.new("media/portal.png", :portal)
    end
  end
  def generate_entity(freq, max_size, array, method)
    if rand(freq) < 2 && array.size < max_size
      array.push(method)
    end
  end

  generate_entity(200, 4, @stars, generate_star)
  generate_entity(100, 7, @aliens, Alien.new)
  generate_entity(1000, 2, @powerups, generate_powerups)
  # if rand(200) < 2 && @stars.size < 4
  #   @stars.push(generate_star)
  # end
  # if rand(100) < 2 && @aliens.size < 7
  #   @aliens.push(Alien.new)
  # end
  # if rand(1000) < 2 && @powerups.size < 2
  #   @powerups.push(generate_powerups)
  # end
end
