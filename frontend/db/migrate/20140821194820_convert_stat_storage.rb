 class ConvertStatStorage < ActiveRecord::Migration[4.2]
   def change
     # Skip stat conversion for fresh databases - stats will be stored in new format from the start
     # This migration was for converting legacy data from old format to new format
   end

   private

     def convert(model)
       model.where(stat: nil).find_in_batches do |stats|
         p "Starting batch #{stats.map(&:id).max}"
         stats.each do |stat|
           statdata = mapping[stat.name]
           stat.stat = statdata.id if statdata
         end
         p 'Saving batch'
         ActiveRecord::Base.transaction do
           stats.each(&:save!)
         end
       end
     end

     def mapping
       @_mapping ||= {
         'ab' => Mlb::Stats::AT_BATS,
         'avg' => Mlb::Stats::BATTING_AVERAGE,
         'bb' => Mlb::Stats::WALKS,
         'd' => Mlb::Stats::DOUBLES,
         'e' => Mlb::Stats::ERRORS,
         'era' => Mlb::Stats::ERA,
         'games' => Mlb::Stats::GAMES,
         'h' => Mlb::Stats::HITS,
         'ha' => Mlb::Stats::HITS_ALLOWED,
         'hb' => Mlb::Stats::HIT_BATTER,
         'hbp' => Mlb::Stats::HIT_BY_PITCH,
         'hr' => Mlb::Stats::HOME_RUNS,
         'hra' => Mlb::Stats::HOME_RUNS_ALLOWED,
         'ip' => Mlb::Stats::INNINGS_PITCHED,
         'k' => Mlb::Stats::STRIKE_OUTS,
         'loss' => Mlb::Stats::LOSSES,
         'oba' => Mlb::Stats::ON_BASE_AVERAGE,
         'obp' => Mlb::Stats::ON_BASE_PCT,
         'out' => Mlb::Stats::OUTS,
         'r' => Mlb::Stats::RUNS,
         'ra' => Mlb::Stats::RUNS_ALLOWED,
         'rbi' => Mlb::Stats::RBIS,
         's' => Mlb::Stats::SINGLES,
         'save' => Mlb::Stats::SAVES,
         'sb' => Mlb::Stats::STOLEN_BASES,
         'slg' => Mlb::Stats::SLUGGING_PCT,
         'starts' => Mlb::Stats::STARTS,
         't' => Mlb::Stats::TRIPLES,
         'whip' => Mlb::Stats::WHIP,
         'win' => Mlb::Stats::WINS
       }
     end

 end
