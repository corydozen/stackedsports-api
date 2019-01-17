namespace :orgs do
  desc 'Add Football team if not present'
  task add_football_team: :environment do
    orgs = Organization.all
    football_sport_id = Sport.find_by(name: 'Football')
    orgs.each do |org|
      if org.teams.present?
        # org has teams, is it a football team
        unless org.teams.any? { |team| team.sport.name == 'Football' }
          p "#{org.name} had a team, but not football, so adding it"
          Team.create(
            name: 'Football',
            organization_id: org.id,
            division: 'I',
            sport_id: football_sport_id.id
          )
        end
      else
        # no teams, need to create
        p "#{org.name} did not have any teams, so adding football"
        Team.create(
          name: 'Football',
          organization_id: org.id,
          division: 'I',
          sport_id: football_sport_id.id
        )
      end
    end
  end
end
