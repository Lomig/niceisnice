class Cashback < ApplicationRecord
  belongs_to :user
  belongs_to :shop
  validates :amount, presence: true
  validates :ticket, presence: true
  # validation de montant sitrictement positif
end
