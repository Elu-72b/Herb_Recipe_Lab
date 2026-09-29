# seed 由来で更新されないマスタタグ（FlavorTag / CautionTag）の
# 検索フォーム用一覧をキャッシュし、毎リクエストの SELECT を避ける。
module TagCacheable
  extend ActiveSupport::Concern

  # キャッシュの保持期間。
  # production の memory_store はプロセスごとにキャッシュを持ち、
  # after_commit の破棄が他プロセスへ伝播しないため、この TTL が実質の上限になる。
  CACHE_EXPIRES_IN = 12.hours

  included do
    # マスタが更新された場合のみキャッシュを破棄する
    after_commit :clear_tag_cache
  end

  class_methods do
    # 検索フォーム用。seed 由来のマスタなので毎リクエスト引かない
    def ordered_cached
      Rails.cache.fetch(cache_key_for(:ordered_by_name), expires_in: CACHE_EXPIRES_IN) do
        order(:name).to_a
      end
    end

    def cache_key_for(suffix)
      "#{model_name.cache_key}/#{suffix}"
    end

    # 指定 id のタグをキャッシュから引く。表示用。
    # キャッシュ生成後に追加されたタグは取りこぼすため、その分だけ DB で補う
    # （黙って欠落させない）。返り値は ordered_cached と同じ name 昇順。
    def find_cached(ids)
      ids = Array(ids).compact.uniq
      return [] if ids.empty?

      wanted = ids.to_set
      tags   = ordered_cached.select { |tag| wanted.include?(tag.id) }
      missing = ids - tags.map(&:id)
      return tags if missing.empty?

      fallback = where(id: missing).to_a
      # キャッシュが古いことが判明したので破棄し、次回は作り直させる
      clear_tag_cache if fallback.any?
      (tags + fallback).sort_by(&:name)
    end

    def clear_tag_cache
      Rails.cache.delete(cache_key_for(:ordered_by_name))
    end
  end

  private

  def clear_tag_cache
    self.class.clear_tag_cache
  end
end
