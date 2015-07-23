require "spec_helper"
require "rolify/shared_examples/shared_examples_for_roles"
require "rolify/shared_examples/shared_examples_for_dynamic"
require "rolify/shared_examples/shared_examples_for_scopes"
require "rolify/shared_examples/shared_examples_for_callbacks"

describe "Using Rolify with has_many :through relationship" do
  context 'with inferred join class' do
    def user_class
      Employee
    end

    def role_class
      Permission
    end

    def rolify_options
      {:role_cname => role_class.to_s,
        :has_many_through => true}
    end

    it_behaves_like Rolify::Role
    it_behaves_like "Role.scopes"
    it_behaves_like Rolify::Dynamic
    it_behaves_like "Rolify.callbacks"
  end

  context 'with custom join class' do
    def user_class
      Person
    end

    def role_class
      Capability
    end

    def rolify_options
      {:has_many_through => true,
       :role_join_cname => "Grant"}
    end

    it_behaves_like Rolify::Role
    it_behaves_like "Role.scopes"
    it_behaves_like Rolify::Dynamic
    it_behaves_like "Rolify.callbacks"
  end
end
