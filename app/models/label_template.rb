class LabelTemplate < ApplicationRecord
  include Filterable

  belongs_to :label_type
  has_many :labels, dependent: :destroy

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :label_type, existence: true
  validates_associated :labels

  accepts_nested_attributes_for :labels

  delegate :dummy_labels, to: :label_fields

  validate :update_unless_published, on: :update

  ##
  # Returns all of the field names as a hash.
  def field_names
    label_fields.to_h
  end

  ##
  # A LabelFields object which will return all of 
  # the field names for the labels.
  # This includes nesting.
  def label_fields
    @label_fields ||= LabelFields.new do |lf|
      labels.each { |label| lf.add(label) }
    end
  end

  ##
  # For use as permitted attributes in the controller
  def self.permitted_attributes
    [
      'name',
      'label_type_id',
      'labels_attributes' => Label.permitted_attributes
    ]
  end

  ##
  # Returns a valid name for a template.
  # If the passed name is not valid or there is no passed name
  # Will create a name with copy on the end.
  def self.valid_name(label_template, name = nil)
    new_name = name || label_template.name
    return new_name unless exists?(name: new_name)
    valid_name(label_template, "#{new_name} copy")
  end

  ##
  # An implementation of dup which allows the name to be changed.
  # Dup the original template. If a name is not passed the name 
  # will be changed to "label_template_name copy"
  # dup each of the labels and add it to the new label template
  # Saving the dup will create a whole new record with new ids.
  def copy(new_name = nil)
    dup.tap do |copy|
      copy.name = LabelTemplate.valid_name(copy, new_name)
      copy.published = false
      copy.labels << labels.collect(&:copy)
      copy.save
    end
  end

  

  private

  def update_unless_published
    if published? || published_was
      errors.add(:base, "A published label template cannot be modified")
    end
  end
end
