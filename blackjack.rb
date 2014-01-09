class Card
  attr_accessor :suit, :value

  def initialize(value, suit)
    @value = value
    @suit = suit
  end

  def to_s
    "#{value} of #{suit}"
  end

end


class Deck
  attr_accessor :deck

  def initialize(num_decks)
    @deck = []
    num_decks.times do 
      %w(2 3 4 5 6 7 8 9 10 Jack Queen King Ace).each do |value|
        %w(Clubs Diamonds Hearts Spades).each do |suit|
          @deck << Card.new(value, suit)
        end
      end
    end
    shuffle!
  end

  def shuffle!
    puts
    puts "The dealer shuffles the cards..."
    @deck.shuffle!
  end

  def draw
    deck.pop
  end

end


class Person

  def score
    total = 0
    @hand.each do |card| 
      if card.value == "Ace"
        total += 11
      elsif card.value.to_i == 0 
        total += 10
      else
        total += card.value.to_i
      end
    end

    @hand.select{ |card| card.value == "Ace" }.count.times do
      total -= 10 if total > MAX_SCORE
    end

    total
  end
end


class Player < Person
  attr_accessor :name, :hand, :busted

  def initialize(n)
    @name = n
    @hand = []
    @busted = false
  end

end


class Dealer < Person
  attr_accessor :hand, :showing, :busted

  def initialize
    @hand = []
    @busted = false
  end

  def showing
    @showing = @hand.slice(1, @hand.length - 1)
  end

end


class Blackjack
  attr_accessor :player, :dealer, :deck

  def initialize 
    setup_game
  end

  def run
    while true
      deal_cards
      show_flop
      if not blackjack?
        player_turn
        if @player.busted == false
          dealer_turn
          if @dealer.busted == false
           resolve_game
          end
        end
      end
      reset_game
      break if not play_again
    end
    thank_player
  end

  def setup_game
    @player = Player.new(get_name)
    @dealer = Dealer.new
    @deck = Deck.new($num_decks)
  end

  def get_name
    puts "Welcome to John Morgan's object-oriented blackjack game! Please enter name:"
    name = gets.chomp
    puts
    puts "Welcome, #{name}!"
    name
  end

  def deal_cards
    puts
    puts "The dealer deals the cards..."
    2.times do
      @player.hand << @deck.draw
      @dealer.hand << @deck.draw
    end
  end

  def show_flop
    puts
    puts "#{@player.name} has:"
    puts @player.hand
    puts "#{@player.name}'s score: #{@player.score}"
    puts
    puts "The dealer is showing:"
    puts @dealer.showing
    puts
  end

  def show_cards
    puts
    puts "#{@player.name} has:"
    puts @player.hand
    puts "#{@player.name}'s score: #{@player.score}"
    puts
    puts "The dealer has:"
    puts @dealer.hand
    puts "The dealer's score: #{@dealer.score}"
    puts
  end
  
  def blackjack?
    if @player.score == 21 
      if @dealer.score == 21
        show_cards
        puts "You have blackjack, but so does the dealer! You draw!"
        return true
      else
        show_cards
        puts "Blackjack! You win!"
        return true
      end
    elsif @dealer.score == 21
      show_cards
      puts "The dealer has blackjack! Sorry, you lose!"
      return true
    end
    false
  end

  def player_turn
    while true 
      puts "What would you like to do, #{@player.name}? Type 'stay' or 'hit':"
      input = gets.chomp
      if input == "stay"
        break
      elsif input == "hit"
        new_card = @deck.draw
        @player.hand << new_card
        puts
        puts "You draw a " + new_card.to_s
        show_flop
      else
        puts
        puts "Sorry, not a valid input."
        show_flop
      end

      if @player.score > MAX_SCORE
        puts "You busted! Sorry, #{@player.name}, but you lose."
        @player.busted = true
        break
      end
    end
  end

  def dealer_turn
    show_cards
    sleep(1)
    while @dealer.score < DEALER_CUTOFF
      new_card = @deck.draw
      @dealer.hand << new_card
      puts "The dealer draws a " + new_card.to_s
      show_cards
      sleep(1)
    end
    if @dealer.score > MAX_SCORE
      puts "The dealer busted! You win, #{@player.name}!"
      @dealer.busted = true
    end
  end

  def resolve_game
    if @player.score > @dealer.score
      puts "You win this round! Congratulations!"
    elsif @player.score < @dealer.score
      puts "The dealer wins! Better luck next time!"
    else
      puts "You draw! It's a push!"
    end
  end

  def reset_game
    @player.hand, @player.busted = [], false
    @dealer.hand, @dealer.busted = [], false
  end

  def play_again
    play_again = false
    while true
      puts
      puts "Play again? Please enter 'yes' or 'no'."
      input = gets.chomp
      if input == "yes"
        play_again = true
        break 
      elsif input == "no"
        break
      else
        puts "Sorry, not a valid input."
      end
    end
    play_again
  end

  def thank_player
    puts
    puts "Thanks for playing!"
    puts
  end

end

MAX_SCORE = 21
DEALER_CUTOFF = 17
$num_decks = 6

Blackjack.new.run






