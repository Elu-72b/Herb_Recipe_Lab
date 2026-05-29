class User < ApplicationRecord
  has_many :recipes, dependent: :destroy
  has_many :herbs, dependent: :nullify
  has_many :tea_reviews, dependent: :destroy
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
end
