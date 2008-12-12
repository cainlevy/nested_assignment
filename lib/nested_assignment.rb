# NestedAssignment
module NestedAssignment
  def self.included(base)
    base.class_eval do
      extend ClassMethods
      
      alias_method_chain :save, :associated
      alias_method_chain :valid?, :associated
      alias_method_chain :changed?, :associated
    end
  end

  module ClassMethods
    # Parallels attr_accessible. Could easily trigger from an association option (e.g. :accessible => true)
    # or even from attr_accessible itself (cool!).
    def accessible_associations(*associations)
      associations.each do |name|
      
        # singular associations
        if [:belongs_to, :has_one].include? self.reflect_on_association(name).macro
          define_method("#{name}_params=") do |row|
            assoc = self.send(name)
            
            record = row[:id].blank? ? assoc.build : [assoc].detect{|r| r.id == row[:id].to_i}
            if row[:_delete]
              record._delete = true
            else
              record.attributes = row
            end
          end
        # plural collections
        else
          define_method("#{name}_params=") do |hash|
            assoc = self.send(name)
            hash.values.each do |row|
              record = row[:id].blank? ? assoc.build : assoc.detect{|r| r.id == row[:id].to_i}
              if row[:_delete]
                record._delete = true
              else
                record.attributes = row
              end
            end
          end
        end
                
      end
    end
  
    def association_names
      @association_names ||= reflect_on_all_associations.map(&:name)
    end
  end
  
  # marks the (associated) record to be deleted in the next deep save
  attr_accessor :_delete
  
  # deep validation of any changed (or new) records.
  # makes sure that any single invalid record will not halt the
  # validation process, so that all errors will be available
  # afterwards.
  def valid_with_associated?
    [changed_associated.all?(&:valid?), valid_without_associated?].all?
  end
  
  # deep saving of any new, changed, or deleted records.
  def save_with_associated
    self.class.transaction do
      changed_associated.all?(&:save) &&
        deletable_associated.all?(&:destroy) &&
        save_without_associated
    end
  end
  
  # Without this, we may not save deeply nested and changed records.
  # For example, suppose that User -> Task -> Tags, and that we change
  # an attribute on a tag but not on the task. Then when we are saving
  # the user, we would want to say that the task had changed so we
  # could then recurse and discover that the tag had changed.
  def changed_with_associated?
    changed_without_associated? or instantiated_associated.any?(&:changed?)
  end
  
  protected
  
  def deletable_associated
    instantiated_associated.select(&:_delete)
  end

  def changed_associated
    instantiated_associated.select(&:changed?)
  end

  def instantiated_associated
    self.class.association_names.collect do |name|
      ivar = "@#{name}"
      association = instance_variable_get(ivar) if instance_variable_defined?(ivar)
      association && association.target
    end.flatten.compact
  end

end
