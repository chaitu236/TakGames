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

    if data[:size] && data[:size].length > 0
      queryf[queryf.count] = "size = ?"
      querys[querys.count] = data[:size]
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
  end

  def get_header(key, val)
    return '['+key+' "'+val.to_s+'"]'+"\n";
  end

  def convert_move(move)
    spl = move.split(' ')

    if spl[0] == 'P'
      #P A4 (C|W)
      sq = spl[1]
      stone = ''
      if spl.length == 3
        stone = (spl[2]=='C')?'C':'S'
      end
      return stone + sq.downcase
    elsif spl[0] == 'M'
      #M A2 A5 2 1
      fl1 = spl[1][0]
      rw1 = spl[1][1]
      fl2 = spl[2][0]
      rw2 = spl[2][1]

      #sq1 = spl[1]
      #sq2 = spl[2]
      dir = ''
      if fl2 == fl1
        dir = (rw2 > rw1)?'+':'-'
      else
        dir = (fl2 > fl1)?'>':'<'
      end

      lst = ''
      liftsize = 0
      for i in (3..spl.length-1).to_a
        lst += spl[i]
        liftsize += spl[i].to_i
      end

      return liftsize.to_s + spl[1].downcase + dir + lst
    end

    return ''
  end

  def get_moves(notation)
    moves = ''
    count = 0
    notation.split(',').each do |move|
      if count%2 == 0
        moves += "\n" + ((count/2)+1).to_s + '.'
      end

      moves += ' '
      moves += convert_move(move)

      count += 1
    end
    return moves
  end

  def get_ptn(game)
    ptn = ''

    wn = (game.date < 1461430800000) ? 'Anon':game.player_white
    bn = (game.date < 1461430800000) ? 'Anon':game.player_black

    ptn += get_header('Site', 'PlayTak.com')
    ptn += get_header('Event', 'Online Play')

    dt = DateTime.strptime((game.date/1000).to_s, '%s').to_s
    dt = (dt.gsub 'T', ' ').gsub '+00:00', ''

    ptn += get_header('Date', dt.split(' ')[0].gsub('-', '.'))
    ptn += get_header('Time', dt.split(' ')[1])

    ptn += get_header('Player1', wn)
    ptn += get_header('Player2', bn)
    ptn += get_header('Result', game.result)
    ptn += get_header('Size', game.size)

    ptn += get_moves("\n" + game.notation)
    return ptn
  end

  def show
    id = params[:id]
    games = Game.where('id = ?', id)

    if(games.length == 1)
      game = games[0]
      ptn = get_ptn(game)

      wn = (game.date < 1461430800000) ? 'Anon':game.player_white
      bn = (game.date < 1461430800000) ? 'Anon':game.player_black
      dt = DateTime.strptime((game.date/1000).to_s, '%s').to_s
      dt = (dt.gsub 'T', ' ').gsub '+00:00', ''

      send_data ptn, :filename => wn + ' vs ' + bn + ' ' + dt.split(' ')[0].gsub('-', '.') + '.ptn'
    end
  end
end
