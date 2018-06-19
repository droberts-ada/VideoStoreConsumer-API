class Customer < ApplicationRecord
  has_many :rentals
  has_many :movies, through: :rentals

  def movies_checked_out_count
    count = 0
    self.rentals.each do |r|
      count += 1 unless r.returned
    end
    return count
  end
end
