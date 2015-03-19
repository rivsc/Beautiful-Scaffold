module DefaultSortingConcern
  extend ActiveSupport::Concern

  included do
      scope :sorting, lambda{ |options|
                attribute = options[:attribute]
                direction = options[:sorting]

                attribute ||= "id"
                direction ||= "DESC"

                order("#{attribute} #{direction}")
              }
  end
end
