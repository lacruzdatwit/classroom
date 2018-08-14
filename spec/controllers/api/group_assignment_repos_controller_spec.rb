# frozen_string_literal: true

require "rails_helper"

RSpec.describe API::GroupAssignmentReposController, type: :controller do
  let(:organization)      { classroom_org }
  let(:user)              { classroom_teacher }
  let(:group_assignment)  { create(:group_assignment, organization: organization, title: "Learn Clojure") }
  let(:group)             { Group.create(title: "The Group", grouping: group_assignment.grouping) }

  describe "GET #index", :vcr do
    before do
      @group_assignment_repo = GroupAssignmentRepo.create(group_assignment: group_assignment, group: group)

      get :index, params: {
        organization_id: organization.slug,
        group_assignment_id: group_assignment.slug,
        access_token: user.api_token
      }
    end

    after do
      GroupAssignmentRepo.destroy_all
      Grouping.destroy_all
    end

    it "returns success" do
      expect(response).to have_http_status(:success)
    end

    context "group assignment repos serializer returns correct attributes" do
      it "returns group title as username" do
        expect(json.first["username"]).to eq(group.title)
      end

      it "returns empty string as display name" do
        expect(json.first["displayName"]).to eq("")
      end
    end
  end

  describe "GET #clone_url", :vcr do
    before do
      @group_assignment_repo = GroupAssignmentRepo.create(group_assignment: group_assignment, group: group)

      get :clone_url, params: {
        organization_id: organization.slug,
        group_assignment_id: group_assignment.slug,
        group_assignment_repo_id: @group_assignment_repo.id,
        access_token: user.api_token,
      }
    end

    after do
      GroupAssignmentRepo.destroy_all
      Grouping.destroy_all
    end

    it "returns success" do
      expect(response).to have_http_status(:success)
    end

    it "returns json with temp clone url" do
      expect(json["temp_clone_url"]).to_not be_nil
    end
  end
end
