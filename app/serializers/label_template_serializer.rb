class LabelTemplateSerializer < ActiveModel::Serializer

  attributes :id, :name, :published

  has_one :label_type

  has_many :labels
end
