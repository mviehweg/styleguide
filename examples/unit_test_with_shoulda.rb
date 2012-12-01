require File.dirname(__FILE__) + '/../test_helper'

class GroupTest < ActiveSupport::TestCase
  context "Group" do
    
    # ASSOCIATIONS
    should belong_to(:company)
    should have_many(:permissions)
    should have_many(:memberships)
    should have_many(:users).through(:memberships)

    # VALIDATIONS
    should "have a valid Factory for tests" do
      assert_valid Factory.build(:group)
    end

    context "when validated" do
      should "be invalid with name longer than 250 characters" do
        assert_invalid Factory.build(:group, :name => "a"*251)
        assert_valid Factory.build(:group, :name => "a"*250)
      end

      should "be invalid without a company" do
        assert_invalid Factory.build(:group, :company => nil)
        assert_valid Factory.build(:group, :company => Factory(:company))
      end
    end

    # CALLBACKS
    context "when destroyed" do
      should "delete all memberships" do
        membership = Factory(:group_membership)
        group = membership.group

        assert_difference('Group::Membership.count', -1) do
          group.destroy
        end
      end

      should "delete all permissions" do
        permission = Factory(:group_permission)
        group = permission.group

        assert_difference('Group::Permission.count', -1) do
          group.destroy
        end
      end
    end

    # METHODS
    context "#update_count" do
      should "raise an exception for an unknown symbol" do
        assert_raise ArgumentError do
          Factory.build(:group).send(:update_count, :wrong, 1)
        end
      end

      context "with a positive number" do
        should "increase a count specified by a symbol" do
          group = Factory.create(:group)

          assert_difference("group.reload.documents_count", 1) do
            group.send(:update_count, :documents, 1)
          end
        end
      end

      context "with a negative number" do
        should "decrement a count specified by a symbol" do
          group = Factory.create(:group)

          assert_difference("group.reload.documents_count", -1) do
            group.decrease_count(:documents)
          end
        end
      end
    end

    context "#increase_count" do
      should "call #update_count and pass 1 as a counter change" do
        group = Factory.build(:group)

        group.stubs(:update_count)
        group.expects(:update_count).with(:documents, 1)

        group.increase_count(:documents)
      end

    end

    context "#decrease_count" do
      should "call #update_count and pass -1 as a counter change" do
        group = Factory.build(:group)

        group.stubs(:update_count)
        group.expects(:update_count).with(:documents, -1)

        group.decrease_count(:documents)
      end
    end
  end
end
