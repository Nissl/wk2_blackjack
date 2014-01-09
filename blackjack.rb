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
    shuffle_deck!
  end

  def shuffle_deck!
    puts
    puts "The dealer shuffles the cards..."
    deck.shuffle!
  end

  def draw
    deck.pop
  end

end


module Hand
  attr_accessor :hand

  def deal_card(deck)
    hand << deck.draw
  end

  def draw_card(deck)
    new_card = deck.draw
    puts
    puts "#{name} draws a " + new_card.to_s
    hand << new_card
  end

  def read_hand
    puts
    puts "#{name} has:"
    hand.each do |card|
      puts card.to_s
    end
    puts "#{name}'s score: #{score}"
  end

  def read_hand_upcard
    puts
    puts "The dealer is showing:" 
    puts "#{hand[1].to_s}"
  end

  def score
    total = 0
    vals = hand.map{ |card| card.value }
    vals.each do |val|
      if val == "Ace"
        total += 11
      else 
        total += (val.to_i == 0 ? 10 : val.to_i)
      end
    end

    vals.select{ |val| val == "Ace" }.count.times do
      total -= 10 if total > MAX_SCORE
    end

    total
  end

  def is_busted?
    score > MAX_SCORE
  end

end


class Player
  include Hand
  attr_accessor :name, :hand, :busted

  def initialize(n)
    @name = n
    @hand = []
  end

end


class Dealer
  include Hand
  attr_accessor :name, :hand, :busted

  def initialize
    @name = "The dealer"
    @hand = []
  end

end


class Blackjack
  attr_accessor :player, :dealer, :deck, :num_decks

  def initialize 
    setup_game(num_decks = 6)
  end

  def run
    while true
      deal_cards
      show_flop
      if not blackjack?
        player_turn
        if !player.is_busted?
          dealer_turn
          if !dealer.is_busted?
           resolve_game
          end
        end
      end
      reset_game
      break if !play_again?
    end
    thank_player
  end

  def setup_game(num_decks)
    @player = Player.new(get_name)
    @dealer = Dealer.new
    @deck = Deck.new(num_decks)
  end

  def get_name
    puts
    puts ("Welcome to John Morgan's object-oriented blackjack game! Please " \
          "enter name:")
    name = gets.chomp
    puts
    puts "Welcome, #{name}!"
    name
  end

  def deal_cards
    puts
    puts "The dealer deals the cards..."
    2.times do
      player.deal_card(deck)
      dealer.deal_card(deck)
    end
  end

  def show_flop
    player.read_hand    
    dealer.read_hand_upcard
  end

  def show_cards
    player.read_hand
    dealer.read_hand
  end
  
  def blackjack?
    if player.score == MAX_SCORE 
      if dealer.score == MAX_SCORE
        show_cards
        puts
        puts "You have blackjack, but so does the dealer! You draw!"
        return true
      else
        show_cards
        puts
        puts "Blackjack! You win!"
        return true
      end
    elsif dealer.score == MAX_SCORE
      show_cards
      puts
      puts "The dealer has blackjack! Sorry, you lose!"
      return true
    end
    false
  end

  def player_turn
    while true 
      puts
      puts "What would you like to do, #{player.name}? Type 'hit' or 'stay':"
      input = gets.chomp
      
      if input == "hit"
        player.draw_card(deck)
        show_flop
      elsif input == "stay"
        puts 
        puts "#{player.name} stays at #{player.score}"
        break
      else
        puts
        puts "Sorry, not a valid input."
        show_flop
        next
      end

      if player.is_busted?
        puts
        puts "You busted! Sorry, #{player.name}, but you lose."
        break
      end
    end
  end

  def dealer_turn
    show_cards
    sleep(1)
    while dealer.score < DEALER_CUTOFF
      dealer.draw_card(deck)
      show_cards
      sleep(1)
    end

    puts
    if dealer.is_busted?  
      puts "The dealer busts! You win, #{player.name}!"
    else
      puts "The dealer stays at #{dealer.score}"
    end
  end

  def resolve_game
    if player.score > dealer.score
      puts
      puts "You win this round! Congratulations!"
    elsif player.score < dealer.score
      puts
      puts "The dealer wins! Better luck next time!"
    else
      puts
      puts "You draw! It's a push!"
    end
  end

  def reset_game
    # Deck intentionally not reset to allow card counting.
    player.hand, dealer.hand = [], []
  end

  def play_again?
    while true
      puts
      puts "Play again? Please enter 'yes' or 'no'."
      input = gets.chomp
      if input == "yes"
        return true
      elsif input == "no"
        return false
      else
        puts "Sorry, not a valid input."
      end
    end
  end

  def thank_player
    puts
    puts "Thanks for playing!"
    puts
    exit
  end

end

MAX_SCORE = 21
DEALER_CUTOFF = 17

Blackjack.new.run






