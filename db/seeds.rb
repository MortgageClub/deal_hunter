# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Setting[:crawler_last_agent_id]  ||= 0
Setting[:crawler_max_agent_id]  ||= 200000
Setting[:default_per_page] ||= 30

if User.where(email: "billy@mortgageclub.co").blank?
  user = User.new(
    email: "billy@mortgageclub.co", name: "Billy Tran",
    password: "12345678", password_confirmation: "12345678", role: "admin"
  )
  user.confirmed_at = Time.zone.now
  user.skip_confirmation_notification!
  user.save
end