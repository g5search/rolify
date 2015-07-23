require 'rolify/adapters/base'
require 'rolify/configure'
require 'rolify/dynamic'
require 'rolify/railtie' if defined?(Rails)
require 'rolify/resource'
require 'rolify/role'

module Rolify
  extend Configure

  attr_writer :adapter, :resource_adapter, :role_cname, :role_table_name,
              :role_join_cname, :role_join_association, :role_join_table_name
  attr_accessor :strict_rolify
  
  @@resource_types = []

  def rolify(options = {})
    include Role
    extend Dynamic if Rolify.dynamic_shortcuts

    self.role_cname = options[:role_cname]
    self.role_table_name = options[:role_table_name]

    if options[:has_many_through]
      unless Rolify.orm == "active_record"
        raise ArgumentError.new("has_many :through is not supported for this orm")
      end

      setup_has_many_through(options)
    else
      setup_has_and_belongs_to_many(options)
    end
    
    self.adapter = Rolify::Adapter::Base.create("role_adapter", self.role_cname, self.name)

    #use strict roles
    self.strict_rolify = true if options[:strict]
  end

  def role_cname
    @role_cname ||= 'Role'
  end

  def role_table_name
    @role_table_name ||= role_cname.tableize.gsub(/\//, "_")
  end

  def role_join_cname
    @role_join_cname ||= "#{self.to_s}#{self.role_cname.to_s}"
  end

  def role_join_association
    @role_join_association ||= role_join_cname.tableize.to_sym
  end

  def role_join_table_name
     @role_join_table_name ||= "#{self.to_s.tableize.gsub(/\//, "_")}_#{self.role_table_name}"
  end

  def adapter
    return self.superclass.adapter unless self.instance_variable_defined? '@adapter'
    @adapter
  end

  def resourcify(association_name = :roles, options = {})
    include Resource

    options.reverse_merge!({ :role_cname => 'Role', :dependent => :destroy })
    resourcify_options = { :class_name => options[:role_cname].camelize, :as => :resource, :dependent => options[:dependent] }
    self.role_cname = options[:role_cname]
    self.role_table_name = self.role_cname.tableize.gsub(/\//, "_")

    has_many association_name, resourcify_options

    self.resource_adapter = Rolify::Adapter::Base.create("resource_adapter", self.role_cname, self.name)
    @@resource_types << self.name
  end

  def resource_adapter
    return self.superclass.resource_adapter unless self.instance_variable_defined? '@resource_adapter'
    @resource_adapter
  end

  def scopify
    require "rolify/adapters/#{Rolify.orm}/scopes.rb"
    extend Rolify::Adapter::Scopes
  end

  def role_class
    return self.superclass.role_class unless self.instance_variable_defined? '@role_cname'
    self.role_cname.constantize
  end

  def self.resource_types
    @@resource_types
  end

  private
  def rolify_callbacks(options)
    options.select do |key, val|
      callbacks = [:before_add, :after_add, :before_remove, :after_remove, :inverse_of]
      callbacks.include?(key.to_sym)
    end
  end

  def setup_has_many_through(options)
    self.role_join_cname = options[:role_join_cname]
    self.role_join_association = options[:role_join_association]

    rolify_options = {:through => role_join_association}
    rolify_options.merge!(rolify_callbacks(options))

    has_many role_join_association, class_name: role_join_cname
    has_many :roles, rolify_options
  end

  def setup_has_and_belongs_to_many(options)
    self.role_join_table_name = options[:role_join_table_name]

    rolify_options = {:class_name => role_cname.camelize}
    if Rolify.orm == "active_record"
      rolify_options.merge!({:join_table => self.role_join_table_name})
    end
    rolify_options.merge!(rolify_callbacks(options))

    has_and_belongs_to_many :roles, rolify_options
  end
end
