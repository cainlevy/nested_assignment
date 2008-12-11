# NestedAssignment
module NestedAssignment
  def self.included(base)
    base.class_eval { extend ClassMethods }
  end

  module ClassMethods
    # Parallels attr_accessible. Could easily trigger from :accessible => true instead.
    def accessible_associations(*associations)
      associations.each do |name|
      
        define_method("#{name}_params=") do |hash|
          assoc = self.send(name)
          hash.values.each do |row|
            record = row[:id].blank? ? assoc.build : assoc.select{|r| r.id == row[:id].to_i}
            if row[:_delete]
              record._delete = true
            else
              record.attributes = row
            end
          end
        end
        
      end
    end
  
    def association_names
      @association_names ||= reflect_on_all_associations.map(&:name)
    end
  end
  
  # marks the record to be deleted in the next save
  attr_accessor :_delete
  
  # deep validation of any changed (or new) records.
  # makes sure that any single invalid record will not halt the
  # validation process, so that all errors will be available
  # afterwards.
  def valid?
    [changed_associated.all?(&:valid?), super].all?
  end
  
  # deep saving of any new, changed, or deleted records.
  def save
    self.class.transaction do
      super
      changed_associated.each(&:save)
      deletable_associated.each(&:destroy)
    end
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
