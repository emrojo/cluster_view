# At the point at which this migration is executed we have two databases co-existing.  We
# migrate the data we need from the legacy tables at this point.
class MigrateLegacyData < ActiveRecord::Migration
  LEGACY_TABLE_TO_MIGRATE = 'legacy_images'

  module Legacy
    class Image < ActiveRecord::Base
      self.table_name = LEGACY_TABLE_TO_MIGRATE
      
      named_scope :valid_position, :conditions => [ 'position BETWEEN 1 AND 16' ]
      named_scope :valid_filename, :conditions => [ 'filename IS NOT NULL' ]

      def self.valid_for_migration
        [ :valid_position, :valid_filename ].inject(self) { |target,scope| target.send(scope) }
      end
    end
  end

  # If the legacy table doesn't exist then we don't actually need to do any work, so the
  # simple thing to do is say there is nothing to migrate!
  class Legacy::Image
    def self.all
      []
    end
  end unless table_exists?(LEGACY_TABLE_TO_MIGRATE)

  # This constants maps the legacy positions to the new sequence.  The array values are the
  # legacy positions, their index within the array is the new position.  So simple reverse
  # lookup, i.e. LEGACY_POSITIONS_TO_NEW_VALUES.index(legacy_position) = new_position
  #
  # It looks like the photographs are taken lane 8-1 then lane 1-8.
  LEGACY_POSITIONS_TO_NEW_VALUES = [
    8,  9,
    7, 10,
    6, 11,
    5, 12,
    4, 13,
    3, 14,
    2, 15,
    1, 16
  ]

  def self.up
    Legacy::Image.valid_for_migration.all.each do |image|
      new_position = LEGACY_POSITIONS_TO_NEW_VALUES.index(image.position.to_i) or raise StandardError, "Legacy position #{ image.position } unmapped!"
      Image.create!(:batch_id => image.batch_id.to_i, :filename => image.filename, :position => new_position)
    end
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration, 'Unable to reverse the legacy data migration'
  end
end