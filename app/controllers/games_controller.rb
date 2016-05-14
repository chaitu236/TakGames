class GamesController < ApplicationController
  def index
  #  @games = Game.all
  end

  def search
    data = params[:game]
    logger.debug('data')
    logger.debug(data)

    queryf = []
    querys = []
    if data[:player_white] && data[:player_white].length > 0
      queryf[queryf.count] = "player_white like ?"
      querys[querys.count] = data[:player_white]
      @player_search = true
    end

    if data[:player_black] && data[:player_black].length > 0
      queryf[queryf.count] = "player_black like ?"
      querys[querys.count] = data[:player_black]
      @player_search = true
    end

    if data[:result] && data[:result].length > 0
      queryf[queryf.count] = "result = ?"
      querys[querys.count] = data[:result]
    end

    queryfinalf=''
    queryf.each do |i| queryfinalf+=i+' and ' end
    queryfinalf = queryfinalf[0..-(' and '.length)]

    queryfinal=[queryfinalf]
    queryfinal+=querys

    @games = Game.where(queryfinal) if queryfinal.length>1

    @games.each do |game|
      if game.date <= 1461430800000
        if @player_search
          @games.remove(game)
        else
          game.player_white = 'Anon'
          game.player_black = 'Anon'
        end
      end
    end
  end
end
