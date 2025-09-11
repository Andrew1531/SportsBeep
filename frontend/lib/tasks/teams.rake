namespace :teams do

  desc "Pull down all of the teams from SportsData and sync them with our database"
  task import: :environment do
    [Mlb, Nfl].each do |mod|
      if mod::Team.count.zero?
        mod::TeamImportWorker.new.perform
        puts "#{mod} Teams imported, count: #{mod::Team.count}"
      else
        puts "No #{mod} teams imported, the database is up-to-date"
      end

      colors = CSV.read Rails.root.join('lib', 'tasks', 'files', "#{mod.name.downcase}-team-colors.csv")
      colors.shift
      colors.each do |color|
        team = mod::Team.all.find { |team| color.second && color.second.include?(team.name) }
        if team && !team.has_colors? && color.third && color.fourth
          puts "Setting colors for #{team}"
          team.update primary_color: color.third, secondary_color: color.fourth
        end
      end

    end
  end

end