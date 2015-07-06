class TvShowSerializer < ActiveModel::Serializer
  attributes :id, :title, :episodes
  self.root = false

  def episodes
    object.episodes.map { |e| {id: e.id, title: e.title } }
  end
end
