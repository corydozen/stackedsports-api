require 'csv'
class BoardUploadJob < ApplicationJob
  queue_as :default

  def perform(scheduled_time)
    upload(scheduled_time)
  end

  def upload(scheduled_time)
    p "Starting board upload at #{Time.at(scheduled_time)}"
    boards = BoardUpload.where(processed: false)

    boards.each do |board|
      # Find RS user
      rs_user = RsUser.find(board.user_id)
      p "User ID: #{rs_user._id}"

      # # get twitter data from handle
      # twitter = Twitter::REST::Client.new do |config|
      #   config.consumer_key        = ENV['RS_TWITTER_API_KEY']
      #   config.consumer_secret     = ENV['RS_TWITTER_API_SECRET']
      #   config.access_token        = rs_user.twitterAccount['oauthToken']
      #   config.access_token_secret = rs_user.twitterAccount['oauthTokenSecret']
      # end

      coach = Coach.new(
        id: rs_user.id,
        email: rs_user.email,
        token: rs_user.twitterAccount['oauthToken'],
        secret: rs_user.twitterAccount['oauthTokenSecret']
      )

      # Find team for RS user
      rs_team = RsTeam.find_by(_wperm: rs_user._id.to_s)
      rs_team_id = "Team$#{rs_team._id}"
      p "Team ID: #{rs_team._id}"

      # Find/Create board with same name and team
      rs_board = RsBoard.find_or_create_by(name: board.board_name, _p_team: rs_team_id) do |b|
        p 'Creating New Board'
        ts = Time.now
        b._id = ApplicationHelper.random_string
        b._created_at = ts
        b._updated_at = ts
        b._wperm = ['*']
        b._rperm = ['*']
        b._acl = { '*' => { 'w' => true, 'r' => true } }
        b.description = ''
        b.athleteRefs = ['abc123']
        b.lastUpdateReason = { type: 'BOARD_CREATED_VIA_CSV' }
      end

      p "Board name: #{rs_board.name}"

      # Remove any existing athletes from the board
      if rs_board.athleteRefs.present?
        p "Removing #{rs_board.athleteRefs.count} athletes from board"
        rs_board.athleteRefs = []
        rs_board.lastUpdateReason = { type: 'CLEARED_ATHETES_FOR_UPLOAD' }
        rs_board.save!
      end

      # Loop over athletes in file adding to team and board
      p "Board File URL: #{board.board.url}"
      athleteRefs = []
      csv = CSV.new(open(board.board.url), headers: true)
      csv.each do |row|
        next unless row['twitter_handle'].present?

        p row
        twitter_handle = row['twitter_handle'].delete('@')
        record_lookup_result = RsAthlete.where(_p_team: rs_team_id, name: row['name'], high_school: row['high_school'])

        notes = {}

        begin
          tw_user = coach.get_twitter_profile(twitter_handle, hydrate: true)
          if tw_user.present?
            tw_params = {
              id: tw_user.id.to_s,
              screenName: tw_user.screen_name.to_s,
              fullName: tw_user.name.to_s,
              bio: tw_user.description.to_s,
              photoUrl: tw_user.profile_image_url_https.to_s,
              following: false,
              site: 'Twitter'
            }
            end
        rescue StandardError => exc
          notes.merge(Time.now.to_s => "Unable to find or use handle: #{twitter_handle}")
          p "Unable to find or use handle: #{twitter_handle}"
        end

        if record_lookup_result.present?
          p "Updating athlete: #{row['name']}"
          rs_ath = record_lookup_result.first
          rs_ath.update(
            name: row['name'],
            nickname: row['nickname'],
            phone: row['phone'],
            email: row['email'],
            grad_year: row['grad_year'],
            high_school: row['high_school'],
            positions: row['positions'],
            lastUpdateReason: { type: 'BOARD_UPLOAD_VIA_CSV' },
            _wperm: ['*'],
            _rperm: ['*'],
            _acl: { '*' => { 'w' => true, 'r' => true } },
            _updated_at: Time.now,
            instagramProfile: nil,
            twitterProfile: (tw_user.present? ? tw_params : {}),
            twitterProfileV11: (tw_user.present? ? tw_params : {}),
            photoUrl: (tw_user.present? ? tw_user.profile_image_url_https.to_s : nil)
          )
        else
          p "Creating athlete: #{row['name']}"
          rs_ath = RsAthlete.create(
            _id: ApplicationHelper.random_string,
            _p_team: rs_team_id,
            name: row['name'],
            nickname: row['nickname'],
            phone: row['phone'],
            email: row['email'],
            grad_year: row['grad_year'],
            high_school: row['high_school'],
            positions: row['positions'],
            lastUpdateReason: { type: 'BOARD_UPLOAD_VIA_CSV' },
            _wperm: ['*'],
            _rperm: ['*'],
            _acl: { '*' => { 'w' => true, 'r' => true } },
            _created_at: Time.now,
            _updated_at: Time.now,
            instagramProfile: nil,
            twitterProfile: (tw_user.present? ? tw_params : {}),
            twitterProfileV11: (tw_user.present? ? tw_params : {}),
            photoUrl: (tw_user.present? ? tw_user.profile_image_url_https.to_s : nil)
          )
        end

        rs_ath.save!
        p rs_ath.name
        # Add athlete to board
        athleteRefs << rs_ath._id
      end
      rs_board.athleteRefs = athleteRefs
      rs_board.save
      board.processed = true
      board.save
    end
    p "Ending board upload at #{Time.now}"
  end
end
