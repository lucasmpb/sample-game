require 'optparse'
require 'gosu'
require_relative 'bullet'
require_relative 'fire'
require_relative 'player'
require_relative 'star'

class SampleWindow < Gosu::Window
  SCREEN_WIDTH = 800
  SCREEN_HEIGHT = 600

  def initialize(options)
    super SCREEN_WIDTH, SCREEN_HEIGHT
    self.caption = "Sample Game"
    @options = options

    @background_image = Gosu::Image.new("media/space.png", :tileable => true)

    @player = Player.new
    @player.warp(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2)

    @star_anim = Gosu::Image::load_tiles("media/star.png", 25, 25)
    @stars = Array.new

    @font = Gosu::Font.new(20)
  end

  def update
    if Gosu::button_down? Gosu::KbLeft or Gosu::button_down? Gosu::GpLeft then
      @player.turn_left
    end
    if Gosu::button_down? Gosu::KbRight or Gosu::button_down? Gosu::GpRight then
      @player.turn_right
    end
    if Gosu::button_down? Gosu::KbUp or Gosu::button_down? Gosu::GpButton0 then
      @player.accelerate
    end
    @player.move
    @player.collect_stars(@stars)

    if rand(100) < 4 and @stars.size < 250 then
      @stars.push(Star.new(@star_anim))
    end
    @stars.each { |star| star.update }
  end

  def draw
    @player.draw
    @background_image.draw(0, 0, 0);
    @stars.each { |star| star.draw }
    @font.draw("Score: #{@player.score}", 10, 10, ZOrder::UI, 1.0, 1.0, 0xff_ffff00)
    if @options[:debug]
      @font.draw("Stars: #{@stars.size}", 700, 10, ZOrder::UI, 1.0, 1.0, 0xff_ffff00)
      @font.draw("FPS: #{1000.0 / update_interval}", 700, 550, ZOrder::UI, 1.0, 1.0, 0xff_ffff00)
    end
  end

  def button_down(id)
    if id == Gosu::KbEscape
      close
    end
    if id == Gosu::KbSpace
      @player.fire_bullet
    end
  end
end

module ZOrder
  Background, Stars, Player, UI = *0..3
end

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: sample.rb [options]"

  opts.on("-d", "--debug", "Show debug info") do |v|
    options[:debug] = v
  end
end.parse!

puts options if options[:debug]

window = SampleWindow.new(options)
window.show

