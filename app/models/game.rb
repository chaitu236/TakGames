class Game < ActiveRecord::Base
  attr_accessible :id, :date, :size, :player_white, :player_black, :notation, :result, :timertime, :timerinc
end
