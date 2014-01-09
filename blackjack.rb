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


class Hand
  attr_accessor :hand

  def initialize
    @hand = []
  end

  def deal_card(deck)
    @hand << deck.draw
  end

  def add_card(card)
    @hand << card
  end

  def read
    hand.each do |card|
      card.to_s
    end
  end

  def show_upcard
    hand.slice(1, @hand.length - 1)
  end

  def each
    hand.each do |card|
      card
    end
  end

  def slice(x, y)
    hand.slice(x, y)
  end

  def length
    hand.length
  end

  def score
    total = 0
    vals = hand.each.map{ |card| card.value }
    vals.each do |val|
      if val == "Ace"
        total += 11
      elsif val.to_i == 0 
        total += 10
      else
        total += val.to_i
      end
    end

    vals.select{ |val| val == "Ace" }.count.times do
      total -= 10 if total > MAX_SCORE
    end

    total
  end

end


module CardReaders

  def total
    hand.score
  end

  def show_hand
    hand.read
  end

  def show_upcard
    hand.show_upcard
  end

end


class Player
  include CardReaders
  attr_accessor :name, :hand, :busted

  def initialize(n)
    @name = n
    @hand = Hand.new
    @busted = false
  end

end


class Dealer
  include CardReaders
  attr_accessor :hand, :busted

  def initialize
    @hand = Hand.new
    @busted = false
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
      player.hand.deal_card(deck)
      dealer.hand.deal_card(deck)
    end
  end

  def show_flop
    puts
    puts "#{player.name} has:"
    puts player.hand.read
    puts "#{player.name}'s score: #{player.total}"
    puts
    puts "The dealer is showing:"
    puts dealer.hand.show_upcard
    puts
  end

  def show_cards
    puts
    puts "#{player.name} has:"
    puts player.hand.read
    puts "#{player.name}'s score: #{player.total}"
    puts
    puts "The dealer has:"
    puts dealer.hand.read
    puts "The dealer's score: #{dealer.total}"
    puts
  end
  
  def blackjack?
    if player.hand.score == 21 
      if dealer.hand.score == 21
        show_cards
        puts "You have blackjack, but so does the dealer! You draw!"
        return true
      else
        show_cards
        puts "Blackjack! You win!"
        return true
      end
    elsif dealer.hand.score == 21
      show_cards
      puts "The dealer has blackjack! Sorry, you lose!"
      return true
    end
    false
  end

  def player_turn
    while true 
      puts "What would you like to do, #{player.name}? Type 'stay' or 'hit':"
      input = gets.chomp
      if input == "stay"
        break
      elsif input == "hit"
        new_card = deck.draw
        player.hand.add_card(new_card)
        puts
        puts "You draw a " + new_card.to_s
        show_flop
      else
        puts
        puts "Sorry, not a valid input."
        show_flop
      end

      if player.hand.score > MAX_SCORE
        puts "You busted! Sorry, #{player.name}, but you lose."
        player.busted = true
        break
      end
    end
  end

  def dealer_turn
    show_cards
    sleep(1)
    while dealer.hand.score < DEALER_CUTOFF
      new_card = deck.draw
      dealer.hand.add_card(new_card)
      puts "The dealer draws a " + new_card.to_s
      show_cards
      sleep(1)
    end
    if dealer.hand.score > MAX_SCORE
      puts "The dealer busts! You win, #{player.name}!"
      dealer.busted = true
    end
  end

  def resolve_game
    if player.hand.score > dealer.hand.score
      puts "You win this round! Congratulations!"
    elsif player.hand.score < dealer.hand.score
      puts "The dealer wins! Better luck next time!"
    else
      puts "You draw! It's a push!"
    end
  end

  def reset_game
    player.hand, player.busted = Hand.new, false
    dealer.hand, dealer.busted = Hand.new, false
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






