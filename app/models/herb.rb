class Herb < ApplicationRecord
  # 旧 string 列 image は has_one_attached :image と名前が衝突し、
  # rails_admin が添付ではなく空のカラム値を読んでしまうため無視する（カラム削除は別 Issue）
  self.ignored_columns += [ "image" ]

  belongs_to :user, optional: true
  has_one_attached :image

  has_many :herb_flavor_tags, dependent: :destroy
  has_many :flavor_tags, through: :herb_flavor_tags

  has_many :herb_functional_tags, dependent: :destroy
  has_many :functional_tags, through: :herb_functional_tags

  has_many :herb_caution_tags, dependent: :destroy
  has_many :caution_tags, through: :herb_caution_tags

  has_many :recipe_herbs, dependent: :destroy

  ACCEPTED_CONTENT_TYPES = %w[image/jpeg image/png image/gif image/webp].freeze

  def self.ransackable_attributes(auth_object = nil)
    %w[name]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[flavor_tags functional_tags caution_tags recipe_herbs]
  end

  # 表示用。中間テーブルだけ preload し、マスタは TagCacheable のキャッシュから引く。
  # 検索は従来どおり flavor_tags / functional_tags / caution_tags の association（SQL join）を使う。
  # View が any? と each で2回呼ぶため、インスタンス単位でメモ化する。
  def cached_flavor_tags
    @cached_flavor_tags ||= FlavorTag.find_cached(herb_flavor_tags.map(&:flavor_tag_id))
  end

  def cached_functional_tags
    @cached_functional_tags ||= FunctionalTag.find_cached(herb_functional_tags.map(&:functional_tag_id))
  end

  def cached_caution_tags
    @cached_caution_tags ||= CautionTag.find_cached(herb_caution_tags.map(&:caution_tag_id))
  end

  validates :name, presence: true, uniqueness: true
  validates :image,
    content_type: ACCEPTED_CONTENT_TYPES,
    size: { less_than_or_equal_to: 5.megabytes },
    allow_blank: true
end
