require 'test_helper'

class ValidatorsTest < ActiveSupport::TestCase
  include ActionView::Helpers::NumberHelper

  test 'presence validator' do
    model = build_model
    model.validates_attachment_presence_of :attach
    record = model.new
    assert !record.valid?
    message = I18n.t('errors.messages.attachment_presence')
    assert record.errors[:attach].include?(message)

    record = model.new(attach: image_upload)
    assert record.valid?
    assert record.errors[:attach].empty?
    record.destroy
  end

  test 'content type regex validator' do
    model = build_model
    model.validates_attachment_content_type_of :attach, with: /\Aimage/
    record = model.new(attach: file_upload)
    assert !record.valid?
    message = I18n.t('errors.messages.attachment_content_type_with')
    assert record.errors[:attach].include?(message)

    record = model.new(attach: image_upload)
    assert record.valid?
    assert record.errors[:attach].empty?
    record.destroy
  end

  test 'content type inclusion validator' do
    model = build_model
    model.validates_attachment_content_type_of :attach, in: %w(image/gif)
    record = model.new(attach: file_upload)
    assert !record.valid?
    message = I18n.t('errors.messages.attachment_content_type_in', types: %w(image/gif).to_sentence)
    assert record.errors[:attach].include?(message)

    record = model.new(attach: image_upload)
    assert record.valid?
    assert record.errors[:attach].empty?
    record.destroy
  end

  test 'size range validator' do
    model = build_model
    model.validates_attachment_size_of :attach, in: 1..20.bytes
    record = model.new(attach: image_upload)
    assert !record.valid?
    message = I18n.t('errors.messages.attachment_size_in', min: number_to_human_size(1.byte), max: number_to_human_size(20.bytes))
    assert record.errors[:attach].include?(message)

    record = model.new(attach: file_upload)
    assert record.valid?
    assert record.errors[:attach].empty?
    record.destroy
  end

  test 'size minimum validator' do
    model = build_model
    model.validates_attachment_size_of :attach, less_than: 20.bytes
    record = model.new(attach: image_upload)
    assert !record.valid?
    message = I18n.t('errors.messages.attachment_size_less_than', count: number_to_human_size(20.bytes))
    assert record.errors[:attach].include?(message)

    record = model.new(attach: file_upload)
    assert record.valid?
    assert record.errors[:attach].empty?
    record.destroy
  end

  test 'size maximum validator' do
    model = build_model
    model.validates_attachment_size_of :attach, greater_than: 20.bytes
    record = model.new(attach: file_upload)
    assert !record.valid?
    message = I18n.t('errors.messages.attachment_size_greater_than', count: number_to_human_size(20.bytes))
    assert record.errors[:attach].include?(message)

    record = model.new(attach: image_upload)
    assert record.valid?
    assert record.errors[:attach].empty?
    record.destroy
  end

  private

  def build_model
    Class.new(Medium) do
      def self.name
        'Medium'
      end
    end
  end

end
