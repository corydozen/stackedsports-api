# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

admin_user = User.create(
  first_name: 'Admin',
  last_name: 'User',
  email: 'admin@stackedsports.com',
  password: 'Neversaydie27!',
  password_confirmation: 'Neversaydie27!'
)

admin_user.add_role :admin
admin_user.activate!

platforms = Platform.create(
  [
    { name: 'Twitter' },
    { name: 'SMS' }
  ]
)

sports = Sport.create(
  [
    { name: 'Football' },
    { name: 'Basketball' }
  ]
)

orgs = Organization.create(
  [
    { name: 'Stacked Sports', nickname: 'Stacked', mascot: '' },
    { name: 'United States Air Force Academy', nickname: 'Air Force', mascot: '' },
    { name: 'University of Akron', nickname: 'Akron', mascot: '' },
    { name: 'University of Alabama', nickname: 'Alabama', mascot: '' },
    { name: 'Appalachian State University', nickname: 'App. State', mascot: '' },
    { name: 'University of Arizona', nickname: 'Arizona', mascot: '' },
    { name: 'Arizona State University', nickname: 'Arizona State', mascot: '' },
    { name: 'University of Arkansas', nickname: 'Arkansas', mascot: '' },
    { name: 'Arkansas State University', nickname: 'Arkansas State', mascot: '' },
    { name: 'United States Military Academy', nickname: 'Army', mascot: '' },
    { name: 'Auburn University', nickname: 'Auburn', mascot: '' },
    { name: 'Ball State University', nickname: 'Ball State', mascot: '' },
    { name: 'Baylor University', nickname: 'Baylor', mascot: '' },
    { name: 'Boise State University', nickname: 'Boise State', mascot: '' },
    { name: 'Boston College', nickname: 'Boston College', mascot: '' },
    { name: 'Bowling Green State University', nickname: 'Bowling Green', mascot: '' },
    { name: 'University of Buffalo', nickname: 'Buffalo', mascot: '' },
    { name: 'Brigham Young University', nickname: 'BYU', mascot: '' },
    { name: 'University of California', nickname: 'California', mascot: '' },
    { name: 'University of Central Florida', nickname: 'Central Florida', mascot: '' },
    { name: 'Central Michigan University', nickname: 'Central Michigan', mascot: '' },
    { name: 'University of North Carolina Charlotte', nickname: 'Charlotte', mascot: '' },
    { name: 'University of Cincinnati', nickname: 'Cincinnati', mascot: '' },
    { name: 'Clemson University', nickname: 'Clemson', mascot: '' },
    { name: 'Coastal Carolina University', nickname: 'Coastal Carolina', mascot: '' },
    { name: 'University of Colorado', nickname: 'Colorado', mascot: '' },
    { name: 'Colorado State University', nickname: 'Colorado State', mascot: '' },
    { name: 'University of Connecticut', nickname: 'Connecticut', mascot: '' },
    { name: 'Duke University', nickname: 'Duke', mascot: '' },
    { name: 'East Carolina University', nickname: 'East Carolina', mascot: '' },
    { name: 'Eastern Michigan University', nickname: 'Eastern Michigan', mascot: '' },
    { name: 'Florida International University', nickname: 'FIU', mascot: '' },
    { name: 'University of Florida', nickname: 'Florida', mascot: '' },
    { name: 'Florida Atlantic University', nickname: 'Florida Atlantic', mascot: '' },
    { name: 'Florida State University', nickname: 'Florida State', mascot: '' },
    { name: 'Fresno State University', nickname: 'Fresno State', mascot: '' },
    { name: 'University of Georgia', nickname: 'Georgia', mascot: '' },
    { name: 'Georgia Southern University', nickname: 'Georgia Southern', mascot: '' },
    { name: 'Georgia State University', nickname: 'Georgia State', mascot: '' },
    { name: 'Georgia Institute of Technology', nickname: 'Georgia Tech', mascot: '' },
    { name: 'University of Hawaii', nickname: 'Hawaii', mascot: '' },
    { name: 'University of Houston', nickname: 'Houston', mascot: '' },
    { name: 'University of Illinois', nickname: 'Illinois', mascot: '' },
    { name: 'Indiana University', nickname: 'Indiana', mascot: '' },
    { name: 'University of Iowa', nickname: 'Iowa', mascot: '' },
    { name: 'Iowa State University', nickname: 'Iowa State', mascot: '' },
    { name: 'The University of Kansas', nickname: 'Kansas', mascot: '' },
    { name: 'Kansas State University', nickname: 'Kansas State', mascot: '' },
    { name: 'Kent State University', nickname: 'Kent State', mascot: '' },
    { name: 'University of Kentucky', nickname: 'Kentucky', mascot: '' },
    { name: 'Liberty University', nickname: 'Liberty', mascot: '' },
    { name: 'University of Louisiana-Lafayette', nickname: 'Louisiana-Lafayette', mascot: '' },
    { name: 'University of Louisiana-Monroe', nickname: 'Louisiana-Monroe', mascot: '' },
    { name: 'Louisiana Tech University', nickname: 'Louisiana Tech', mascot: '' },
    { name: 'University of Louisville', nickname: 'Louisville', mascot: '' },
    { name: 'Louisiana State University', nickname: 'LSU', mascot: '' },
    { name: 'Marshall University', nickname: 'Marshall', mascot: '' },
    { name: 'University of Maryland', nickname: 'Maryland', mascot: '' },
    { name: 'University of Massachusetts', nickname: 'Massachusetts', mascot: '' },
    { name: 'University of Memphis', nickname: 'Memphis', mascot: '' },
    { name: 'University of Miami (FL)', nickname: 'Miami (FL)', mascot: '' },
    { name: 'Miami University', nickname: 'Miami (OH)', mascot: '' },
    { name: 'University of Michigan', nickname: 'Michigan', mascot: '' },
    { name: 'Michigan State University', nickname: 'Michigan State', mascot: '' },
    { name: 'Middle Tennessee State University', nickname: 'Middle Tennessee', mascot: '' },
    { name: 'University of Minnesota', nickname: 'Minnesota', mascot: '' },
    { name: 'Mississippi State University', nickname: 'Mississippi State', mascot: '' },
    { name: 'University of Missouri', nickname: 'Missouri', mascot: '' },
    { name: 'The United States Naval Academy', nickname: 'Navy', mascot: '' },
    { name: 'North Carolina State University', nickname: 'NC State', mascot: '' },
    { name: 'University of Nebraska', nickname: 'Nebraska', mascot: '' },
    { name: 'University of Nevada', nickname: 'Nevada', mascot: '' },
    { name: 'University of New Mexico', nickname: 'New Mexico', mascot: '' },
    { name: 'New Mexico State University', nickname: 'New Mexico State', mascot: '' },
    { name: 'University of North Carolina', nickname: 'North Carolina', mascot: '' },
    { name: 'Northern Illinois University', nickname: 'Northern Illinois', mascot: '' },
    { name: 'University of North Texas', nickname: 'North Texas', mascot: '' },
    { name: 'Northwestern University', nickname: 'Northwestern', mascot: '' },
    { name: 'University of Notre Dame', nickname: 'Notre Dame', mascot: '' },
    { name: 'Ohio University', nickname: 'Ohio', mascot: '' },
    { name: 'The Ohio State University', nickname: 'Ohio State', mascot: '' },
    { name: 'University of Oklahoma', nickname: 'Oklahoma', mascot: '' },
    { name: 'Oklahoma State University', nickname: 'Oklahoma State', mascot: '' },
    { name: 'Old Dominion University', nickname: 'Old Dominion', mascot: '' },
    { name: 'University of Mississippi', nickname: 'Ole Miss', mascot: '' },
    { name: 'University of Oregon', nickname: 'Oregon', mascot: '' },
    { name: 'Oregon State University', nickname: 'Oregon State', mascot: '' },
    { name: 'Penn State University', nickname: 'Penn State', mascot: '' },
    { name: 'University of Pittsburgh', nickname: 'Pittsburgh', mascot: '' },
    { name: 'Purdue University', nickname: 'Purdue', mascot: '' },
    { name: 'Rice University', nickname: 'Rice', mascot: '' },
    { name: 'Rutgers University', nickname: 'Rutgers', mascot: '' },
    { name: 'San Diego State University', nickname: 'San Diego State', mascot: '' },
    { name: 'San Jose State University', nickname: 'San Jose State', mascot: '' },
    { name: 'University of South Alabama', nickname: 'South Alabama', mascot: '' },
    { name: 'University of South Carolina', nickname: 'South Carolina', mascot: '' },
    { name: 'Southern Methodist University', nickname: 'Southern Methodist University', mascot: '' },
    { name: 'The University of Southern Mississippi', nickname: 'Southern Miss', mascot: '' },
    { name: 'University of South Florida', nickname: 'South Florida', mascot: '' },
    { name: 'StackedSports', nickname: 'StackedSports', mascot: '' },
    { name: 'Stanford University', nickname: 'Stanford', mascot: '' },
    { name: 'Syracuse University', nickname: 'Syracuse', mascot: '' },
    { name: 'Temple University', nickname: 'Temple', mascot: '' },
    { name: 'University of Texas', nickname: 'Texas', mascot: '' },
    { name: 'Texas A&M University', nickname: 'Texas A&M', mascot: '' },
    { name: 'Texas Christian University', nickname: 'Texas Christian', mascot: '' },
    { name: 'Texas State University', nickname: 'Texas State', mascot: '' },
    { name: 'Texas Tech University', nickname: 'Texas Tech', mascot: '' },
    { name: 'University of Toledo', nickname: 'Toledo', mascot: '' },
    { name: 'Troy University', nickname: 'Troy', mascot: '' },
    { name: 'Tulane University', nickname: 'Tulane', mascot: '' },
    { name: 'Tulsa University', nickname: 'Tulsa', mascot: '' },
    { name: 'University of Alabama Birmingham', nickname: 'UAB', mascot: '' },
    { name: 'University of California Los Angeles', nickname: 'UCLA', mascot: '' },
    { name: 'University of Tennessee', nickname: 'University of TN', mascot: '' },
    { name: 'University of Nevada Las Vegas', nickname: 'UNLV', mascot: '' },
    { name: 'University of Southern California', nickname: 'USC', mascot: '' },
    { name: 'University of Utah', nickname: 'Utah', mascot: '' },
    { name: 'Utah State University', nickname: 'Utah State', mascot: '' },
    { name: 'University of Texas El Paso', nickname: 'UTEP', mascot: '' },
    { name: 'University of Texas San Antonio', nickname: 'UTSA', mascot: '' },
    { name: 'Vanderbilt University', nickname: 'Vanderbilt', mascot: '' },
    { name: 'University of Virginia', nickname: 'Virginia', mascot: '' },
    { name: 'Virginia Tech University', nickname: 'Virginia Tech', mascot: '' },
    { name: 'Wake Forest University', nickname: 'Wake Forest', mascot: '' },
    { name: 'University of Washington', nickname: 'Washington', mascot: '' },
    { name: 'Washington State University', nickname: 'Washington State', mascot: '' },
    { name: 'Western Kentucky University', nickname: 'Western Kentucky', mascot: '' },
    { name: 'Western Michigan', nickname: 'Western Michigan', mascot: '' },
    { name: 'West Virginia University', nickname: 'West Virginia', mascot: '' },
    { name: 'University of Wisconsin', nickname: 'Wisconsin', mascot: '' },
    { name: 'University of Wyoming', nickname: 'Wyoming', mascot: '' }
  ]
)

conferences = Conference.create(
  [
    { name: 'ACC', is_power_five: true, sort: 0, football_subdivision: 'FBS' },
    { name: 'Big 10', is_power_five: true, sort: 1, football_subdivision: 'FBS' },
    { name: 'Big 12', is_power_five: true, sort: 2, football_subdivision: 'FBS' },
    { name: 'Pac12', is_power_five: true, sort: 3, football_subdivision: 'FBS' },
    { name: 'SEC', is_power_five: true, sort: 4, football_subdivision: 'FBS' },
    { name: 'Independent', is_power_five: false, sort: 5, football_subdivision: 'FBS' },
    { name: 'American', is_power_five: false, sort: 999_999, football_subdivision: 'FBS' },
    { name: 'Big Sky', is_power_five: false, sort: 999_999, football_subdivision: 'FCS' },
    { name: 'Big South', is_power_five: false, sort: 999_999, football_subdivision: 'FCS' },
    { name: 'CAA', is_power_five: false, sort: 999_999, football_subdivision: 'FCS' },
    { name: 'C_USA', is_power_five: false, sort: 999_999, football_subdivision: 'FBS' },
    { name: 'Independent', is_power_five: false, sort: 999_999, football_subdivision: 'FCS' },
    { name: 'Ivy League', is_power_five: false, sort: 999_999, football_subdivision: 'FCS' },
    { name: 'MAC', is_power_five: false, sort: 999_999, football_subdivision: 'FBS' },
    { name: 'MEAC', is_power_five: false, sort: 999_999, football_subdivision: 'FCS' },
    { name: 'MVFC', is_power_five: false, sort: 999_999, football_subdivision: 'FCS' },
    { name: 'Mountain West', is_power_five: false, sort: 999_999, football_subdivision: 'FBS' },
    { name: 'NEC', is_power_five: false, sort: 999_999, football_subdivision: 'FCS' },
    { name: 'OVC', is_power_five: false, sort: 999_999, football_subdivision: 'FCS' },
    { name: 'PFL', is_power_five: false, sort: 999_999, football_subdivision: 'FCS' },
    { name: 'Patriot', is_power_five: false, sort: 999_999, football_subdivision: 'FCS' },
    { name: 'SLC', is_power_five: false, sort: 999_999, football_subdivision: 'FCS' },
    { name: 'SWAC', is_power_five: false, sort: 999_999, football_subdivision: 'FCS' },
    { name: 'SoCon', is_power_five: false, sort: 999_999, football_subdivision: 'FCS' },
    { name: 'Sun Belt', is_power_five: false, sort: 999_999, football_subdivision: 'FBS' }
  ]
)

co_email_setting = CoEmailSetting.create(
  campaign_id: '20745933f9',
  list_id: 'f6c6d617a6',
  header_text: "Here's a look at all the offers and commit tweets from yesterday. <br>Brought to you by RecruitSuite powered by <a href=\"http://Stackedsports.com\">Stacked Sports</a>",
  commit_keywords: 'comit,commit,commits,comitt,c o m m i t,c-o-m-m-i-t,committing,committed,c o m m i t t e d,committment',
  offer_keywords: 'ofer,offer,offers,offering,offered,o f f e r,o-f-f-e-r,o f f e r e d,o-f-f-e-r-e-d'
)

# temp_athletes = TempAthlete.create(
#   [
#     { first_name: 'Jalen', last_name: 'Hall', twitter_handle: 'futureoffig', priority: 9 },
#     { first_name: 'Will', last_name: 'Craig', twitter_handle: 'will_craig_22', priority: 9 },
#     { first_name: 'Chase', last_name: 'Williams', twitter_handle: '_ujdkchase', priority: 8 },
#     { first_name: 'Kenyatta', last_name: 'Watson', twitter_handle: 'ballhawk36', priority: 8 },
#     { first_name: 'Eric', last_name: 'Fuller Jr.', twitter_handle: 'ericfuller2000', priority: 7 },
#     { first_name: 'Tariq', last_name: 'Bracy', twitter_handle: 'bracytariq', priority: 7 },
#     { first_name: 'Olaijah', last_name: 'Griffin', twitter_handle: 'olaijahgriffin', priority: 7 },
#     { first_name: 'Amon-Ra', last_name: 'St.Brown', twitter_handle: 'amonra_stbrown', priority: 7 },
#     { first_name: 'Dawson', last_name: 'Jaramillo', twitter_handle: 'dawsonjaramillo', priority: 7 },
#     { first_name: 'Tj', last_name: 'Pledger', twitter_handle: 'uno_tj', priority: 7 }
#   ]
# )

positions_list = Position.create(
  [
    { name: 'Quarterback', abbreviation: 'QB', standardized_name: 'Quarterback', role: 'Offense' },
    { name: 'Center', abbreviation: 'C', standardized_name: 'Center', role: 'Offense' },
    { name: 'Offensive Guard', abbreviation: 'OG', standardized_name: 'Offensive Guard', role: 'Offense' },
    { name: 'Offensive Tackle', abbreviation: 'OT', standardized_name: 'Offensive Tackle', role: 'Offense' },
    { name: 'Half Back', abbreviation: 'HB', standardized_name: 'Running Back', role: 'Offense' },
    { name: 'Full Back', abbreviation: 'FB', standardized_name: 'Running Back', role: 'Offense' },
    { name: 'Wide Receiver', abbreviation: 'WR', standardized_name: 'Wide Receiver', role: 'Offense' },
    { name: 'Tight End', abbreviation: 'TE', standardized_name: 'Tight End', role: 'Offense' },
    { name: 'Defensive Tackle', abbreviation: 'DT', standardized_name: 'Defensive Tackle', role: 'Defense' },
    { name: 'Defensive End', abbreviation: 'DE', standardized_name: 'Defensive End', role: 'Defense' },
    { name: 'Linebacker', abbreviation: 'LB', standardized_name: 'Linebacker', role: 'Defense' },
    { name: 'Middle Linebacker', abbreviation: 'MLB', standardized_name: 'Linebacker', role: 'Defense' },
    { name: 'Outside Linebacker', abbreviation: 'OLB', standardized_name: 'Linebacker', role: 'Defense' },
    { name: 'Cornerback', abbreviation: 'CB', standardized_name: 'Cornerback', role: 'Defense' },
    { name: 'Safety', abbreviation: 'S', standardized_name: 'Safety', role: 'Defense' },
    { name: 'Kicker', abbreviation: 'K', standardized_name: 'Kicker', role: 'Special' },
    { name: 'Holder', abbreviation: 'H', standardized_name: 'Holder', role: 'Special' },
    { name: 'Long Snapper', abbreviation: 'LS', standardized_name: 'Long Snapper', role: 'Special' },
    { name: 'Punter', abbreviation: 'P', standardized_name: 'Punter', role: 'Special' },
    { name: 'Kickoff Specialist', abbreviation: 'KOS', standardized_name: 'Kickoff Specialist', role: 'Special' },
    { name: 'Kick Returner', abbreviation: 'KR', standardized_name: 'Returner', role: 'Special' },
    { name: 'Punt Returner', abbreviation: 'PR', standardized_name: 'Returner', role: 'Special' }
  ]
)

Position.all.each { |p| Tag.find_or_create_by(name: p.abbreviation.downcase, group: p.role.downcase) }
