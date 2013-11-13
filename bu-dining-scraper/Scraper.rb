require 'rubygems'
require 'nokogiri'
require 'open-uri'

=begin
WEST_URL = "#{BASE_URL}/the-fresh-food-co-at-west-campus/menu/"
MARCIANO_URL = "#{BASE_URL}/marciano-commons/menu/"
WARREN_URL = "#{BASE_URL}/warren-towers/menu/"
=end

class Scraper
  attr_accessor :goodscore, :gooditems, :badscore, :baditems
  @@BASE_URL = "http://www.bu.edu/dining/where-to-eat/residence-dining"
  def initialize(menu_url)
    @menu_url = "#{@@BASE_URL}#{menu_url}"
    @goodscore = 0
    @gooditems = []
    @badscore = 0
    @baditems = []
    @items = []
    @meals_hash = Hash.new
  end

  def getItems
    page = Nokogiri::HTML(open(@menu_url))
    #meals_list = page.css('div.mealgroup')
    #puts meals_list
    time = Time.new
    currHour = time.hour
    if currHour > 3 and  currHour < 11 #breakfast
    	item_list = page.css('div.breakfast ul.items span.item-menu-name')
    	puts ('breakfast time')
    end
    if currHour > 11 and  currHour < 17  #breakfast
    	item_list = page.css('div.lunch ul.items span.item-menu-name')
    	puts ('lunch time')
    end
    if currHour > 17 and  currHour < 3 #breakfast
    	item_list = page.css('div.dinner ul.items span.item-menu-name')
    	puts ('dinner time')
    end
    item_list.each do |item|
      @items << item.content
    end
    @items.uniq!
  end

  def calcScore
    getItems
    #checks if each item from 'favorites list' is in the each item name
    File.readlines('favorites.list').each do |goodword|
      @items.each do |item|
        if item.downcase.include?(goodword.downcase)
          @goodscore += 1
          @gooditems << item
        end
      end
    end
    #checks if each item from 'dislikes list' is in the each item name
    File.readlines('dislikes.list').each do |badword|
      @items.each do |item|
        if item.downcase.include?(badword.downcase)
          @badscore += 1
          @baditems << item;
        end
      end
    end
    @baditems.uniq!
    @gooditems.uniq!
  end

  def scoreERB
    calcScore
    %{
     <h1><%= @menu_url %></h1>
     <br />
     <div>good matches:  <%= @goodscore %></div>
     <div>bad matches: <%= @badscore $></div>
     <div><h1>total score: <%= @goodscore + @badscore %></h1></div>
   }
  end

  def goodMealsERB
    %{
      <h1>Good Matches</h1>
      <br />
      <ul>
      <% @gooditems.each do |item| %>
        <li>item</li>
      <% end %>
      </ul>
    }
  end

  def badMealsERB
    %{
      <h1>Bad Matches</h1>
      <br />
      <ul>
      <% @baditems.each do |item| %>
        <li>item</li>
      <% end %>
      </ul>
    }
  end

  def allMealsERB
    getItems
    %{
     <h1>All Menu Items</h1>
     <br />
     <ul>
     <% @items.each do |item| %>
      <li><%= item %></li>
     <% end %>
     </ul>
   }
  end

end

west = Scraper.new("/the-fresh-food-co-at-west-campus/menu/")
#west.calcScore()
#puts west.baditems
puts west.getItems.inspect
