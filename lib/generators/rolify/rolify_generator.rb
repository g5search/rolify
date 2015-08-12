module Rolify
  module Generators
    class RolifyGenerator < Rails::Generators::NamedBase
      Rails::Generators::ResourceHelpers

      source_root File.expand_path('../templates', __FILE__)
      argument :user_cname, :type => :string, :default => "User"

      class_option :has_many_through, :type => :boolean,
                                      :default => false,
                                      :desc => "Define User-Role association using has_many :through"

      namespace :rolify
      hook_for :orm, :required => true

      desc "Generates a model with the given NAME and a migration file."

      def self.start(args, config)
        user_cname = args.size > 1 ? args[1] : "User"
        args.insert(1, user_cname) # 0 being the view name
        super
      end
      
      def inject_user_class
        invoke "rolify:user", [ user_cname, class_name ], :orm => options.orm,
                                                          :has_many_through => options.has_many_through
      end

      def copy_initializer_file
        template "initializer.rb", "config/initializers/rolify.rb"
      end
      
      def show_readme
        if behavior == :invoke
          readme "README"
        end
      end
    end
  end
end
