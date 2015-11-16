class Agent < ActiveRecord::Base
  has_many :deals
  has_many :messages, as: :messageable, dependent: :destroy

  validates :full_name, :first_name, :phone, :email, presence: true

  def to_s
    full_name ? full_name : first_name
  end

  def self.to_csv
    CSV.generate do |csv|
      csv << column_names
      all.each do |result|
        csv << result.attributes.values_at(*column_names)
      end
    end
  end

end
