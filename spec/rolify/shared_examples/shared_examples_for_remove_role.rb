shared_examples_for "#remove_role_examples" do |param_name, param_method|
  context "using #{param_name} as parameter" do
    context "removing a global role", :scope => :global do
      let(:remove_role) { subject.remove_role(role_name.send(param_method)) }

      context "being a global role of the user" do
        let(:role_name) { "admin" }
        it "should remove one role" do
          expect { remove_role }.to change { subject.roles.size }.by(-1)
        end

        it "should not have the global role" do
          remove_role
          expect(subject).to_not have_role(role_name.send(param_method))
        end
      end

      context "being a class scoped role to the user" do
        let(:role_name) { "manager" }

        it "should remove one role" do
          expect { remove_role }.to change { subject.roles.size }.by(-1)
        end

        it "should not have the class scoped role" do
          remove_role
          expect(subject).to_not have_role(role_name.send(param_method), Group)
        end
      end

      context "being instance scoped roles to the user" do
        let(:role_name) { "moderator" }
        it "should remove two roles" do
          expect { remove_role }.to change { subject.roles.size }.by(-2)
        end

        it "should not have the forum instance scoped role" do
          remove_role
          expect(subject).to_not have_role(role_name.send(param_method), Forum.last)
        end

        it "should not have the group instance scoped role" do
          remove_role
          expect(subject).to_not have_role(role_name.send(param_method), Group.last)
        end
      end

      context "not being a role of the user" do
        let(:role_name) { "superhero" }

        it "should not change the assigned roles" do
          expect { remove_role }.to_not change { subject.roles.size }
        end
      end

      context "used by another user" do
        let(:role_name) { "staff" }

        before do
          user = user_class.last
          user.add_role role_name.send(param_method)
        end

        it "should remove the role from the subject user" do
          remove_role
          expect(subject).to_not have_role(role_name.send(param_method))
        end

        it "should not remove the role from the data store" do
          expect { remove_role }.to_not change { role_class.count }
        end
      end

      context "not used by anyone else" do
        let(:role_name) { "nobody" }

        before do
          subject.add_role role_name.send(param_method)
        end

        it "should remove the role entirely from the data store" do
          expect { remove_role }.to change { role_class.count }.by(-1)
        end
      end
    end

    context "removing a class scoped role", :scope => :class do
      let(:remove_role) { subject.remove_role(role_name.send(param_method), scoped_class) }

      context "being a global role of the user" do
        let(:role_name) { "warrior" }
        let(:scoped_class) { Forum }

        it "should not remove the role from the user" do
          expect { remove_role }.to_not change { subject.roles.size }
        end
      end

      context "being a class scoped role to the user" do
        let(:role_name) { "manager" }
        let(:scoped_class) { Forum }

        it "should remove one role" do
          expect { remove_role }.to change { subject.roles.size }.by(-1)
        end

        it "should remove the correct scoped role" do
          remove_role
          expect(subject).to_not have_role(role_name.send(param_method), scoped_class)
        end
      end

      context "being instance scoped role to the user" do
        let(:role_name) { "moderator" }
        let(:scoped_class) { Forum}

        it "should remove one role" do
          expect { remove_role }.to change { subject.roles.size }.by(-1)
        end

        it "should remove the role for instances of the scoped class" do
          remove_role
          expect(subject).to_not have_role(role_name.send(param_method), scoped_class.last)
        end

        it "should not remove the role for instances of other classes" do
          remove_role
          expect(subject).to have_role(role_name.send(param_method), Group.last)
        end
      end

      context "not being a role of the user" do
        let(:role_name) { "manager" }
        let(:scoped_class) { Group }

        it "should not remove any roles" do
          expect { remove_role }.to_not change { subject.roles.size }
        end
      end
    end

    context "removing a instance scoped role", :scope => :instance do
      let(:remove_role) { subject.remove_role(role_name.send(param_method), scoped_instance) }

      context "being a global role of the user" do
        let(:role_name) { "soldier" }
        let(:scoped_instance) { Group.first }

        it "should not remove any roles" do
          expect { remove_role }.to_not change { subject.roles.size }
        end
      end

      context "being a class scoped role to the user" do
        let(:role_name) { "visitor" }
        let(:scoped_instance) { Forum.first }

        it "should not remove any roles" do
          expect { remove_role }.to_not change { subject.roles.size }
        end
      end

      context "being instance scoped role to the user" do
        let(:role_name) { "moderator" }
        let(:scoped_instance) { Forum.first }

        it "should remove one role" do
          expect { remove_role }.to change { subject.roles.size }.by(-1)
        end

        it "should remove the role for the scoped instance" do
          remove_role
          expect(subject).to_not have_role(role_name.send(param_method), scoped_instance)
        end
      end

      context "not being a role of the user" do
        let(:role_name) { "anonymous" }
        let(:scoped_instance) { Forum.first }

        it "should not remove any roles" do
          expect { remove_role }.to_not change { subject.roles.size }
        end
      end
    end
  end
end
