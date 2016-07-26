# frozen_string_literal: true
module Cistern::Associations

  # Lists the associations defined on the resource
  # @return [Hash{Symbol=>Array}] mapping of association type to name
  def associations
    @associations ||= Hash.new { |h,k| h[k] = [] }
  end

  def has_many(name, scope)
    reader_method = name
    writer_method = "#{name}="

    attribute name, type: :array

    define_method reader_method do
      collection = instance_exec(&scope)
      records = attributes[name] || []

      collection.load(records)
    end

    define_method writer_method do |models|
      attributes[name] = Array(models).map do |model|
        model.respond_to?(:attributes) ? model.attributes : model
      end
    end

    associations[:has_many] << name
  end

  def belongs_to(name, block)
    reader_method = name

    attribute name

    define_method reader_method do
      attributes[name] ||= instance_exec(&block)
    end

    associations[:belongs_to] << name
  end
end
