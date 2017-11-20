require 'open-uri'
require 'json'

class GamesController < ApplicationController

  def generate_grid(grid_size)
    # TODO: generate random grid of letters

    new_array = []
    grid_size.times do
      new_array << ('A'..'Z').to_a.sample[0, grid_size]
    end
    new_array
  end

  def compute_score(word, time_taken)
    {
      score: word.length - (time_taken * 0.1),
      time: time_taken,
      message: "well done <strong>#{word.upcase}</strong> is a valid English word !".html_safe
    }
  end


  def run_game(word, letters, start_time, end_time)
    # TODO: runs the game and return detailed hash of result
    # Time taken to answer
    time_taken = (end_time.to_date - start_time.to_date)
    # O) get the API of LE WAGON and parse it !
    url_lewagon_api = "https://wagon-dictionary.herokuapp.com/#{word}"
    is_english_word_parsed = JSON.parse(open(url_lewagon_api).read)
    # 1) your word is an actual English word
    if is_english_word_parsed["found"]
      # 2) that every letter in your word appears in the grid (remember you can only use each letter once).
      splitted_word = word.upcase.split("")
      verif = splitted_word.all? do |letter|
        splitted_word.count(letter) <= letters.count(letter)
      end
      if verif
        # 3) calculate the score
        compute_score(word, time_taken)
      else
        { score: 0, time: time_taken, message: "sorry but <strong>#{word.upcase}</strong> can not be built out of #{letters} ".html_safe }
      end
    else
      { score: 0, time: time_taken, message: "sorry but <strong>#{word.upcase}</strong>  does not a valid English word".html_safe }
    end
  end

  def new
    @start_time = Time.now
    @letters = generate_grid(10)
  end

  def score
    @end_time = Time.now
    @word = params[:word]
    @letters = params[:letters].chars
    @start_time = params[:start_time]
    @result = run_game(@word, @letters, @start_time, @end_time)
  end


end
