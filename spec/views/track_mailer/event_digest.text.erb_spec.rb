require 'spec_helper'

RSpec.describe "track_mailer/event_digest" do
  let(:user) { FactoryBot.create(:user, :name => "Test Us'r") }
  let(:body) { FactoryBot.create(:public_body, :name => "Apostrophe's") }
  let(:request) do
    FactoryBot.create(:info_request_with_incoming,
                      :public_body => body,
                      :user => user,
                      :title => "Request apostrophe's data")
  end
  let(:track) { FactoryBot.create(:search_track, :tracking_user => user) }
  let(:xapian_search) do
    double('xapian search', :results => [event], :words_to_highlight => 'test')
  end

  before do
    allow(AlaveteliConfiguration).to receive(:site_name).
      and_return("l'Information")
  end

  describe "tracking a response" do
    let(:event) do
      FactoryBot.create(:response_event,
                        :incoming_message => request.incoming_messages.last,
                        :info_request => request)
    end

    it "does not add HTMLEntities to the request title" do
      result = { :model => event }
      assign(:email_about_things, [[track, [result], xapian_search]])
      render
      expect(response).to match("-- Request apostrophe's data --")
    end

    it "does not add HTMLEntities to the public body name" do
      result = { :model => event }
      assign(:email_about_things, [[track, [result], xapian_search]])
      render
      expect(response).to match("Apostrophe's sent a response")
    end

    it "does not add HTMLEntities to the user name" do
      result = { :model => event }
      assign(:email_about_things, [[track, [result], xapian_search]])
      render
      expect(response).to match("sent a response to Test Us'r")
    end

    context 'when info request is external' do
      let(:request) { FactoryBot.create(:info_request, :external) }

      it 'uses "An anonymous user" as the user name' do
        result = { model: event }
        assign(:email_about_things, [[track, [result], xapian_search]])
        render
        expect(response).to match('sent a response to An anonymous user')
      end
    end
  end

  describe "tracking a followup" do
    let(:event) do
      FactoryBot.create(:response_event,
                        :outgoing_message => request.outgoing_messages.last,
                        :info_request => request,
                        :event_type => 'followup_sent')
    end

    it "does not add HTMLEntities to the request title" do
      result = { :model => event }
      assign(:email_about_things, [[track, [result], xapian_search]])
      render
      expect(response).to match("-- Request apostrophe's data --")
    end

    it "does not add HTMLEntities to the public body name" do
      result = { :model => event }
      assign(:email_about_things, [[track, [result], xapian_search]])
      render
      expect(response).to match("message to Apostrophe's")
    end

    it "does not add HTMLEntities to the user name" do
      result = { :model => event }
      assign(:email_about_things, [[track, [result], xapian_search]])
      render
      expect(response).to match("Test Us'r sent a follow up message")
    end
  end

  describe "tracking a comment" do
    let(:comment) do
      FactoryBot.create(:comment, :info_request => request, :user => user)
    end
    let(:event) do
      FactoryBot.create(:info_request_event,
                        :comment => comment,
                        :info_request => request,
                        :event_type => 'comment')
    end

    it "does not add HTMLEntities to the request title" do
      result = { :model => event }
      assign(:email_about_things, [[track, [result], xapian_search]])
      render
      expect(response).to match("-- Request apostrophe's data --")
    end

    it "does not add HTMLEntities to the user name" do
      result = { :model => event }
      assign(:email_about_things, [[track, [result], xapian_search]])
      render
      expect(response).to match("Test Us'r added an annotation")
    end
  end

  # this is unlikely to happen in real life, but happens in the test code
  describe "tracking a sent event" do
    let(:event) do
      FactoryBot.create(:info_request_event,
                        :outgoing_message => request.outgoing_messages.last,
                        :info_request => request,
                        :event_type => 'sent')
    end

    it "does not add HTMLEntities to the request title" do
      result = { :model => event }
      assign(:email_about_things, [[track, [result], xapian_search]])
      render
      expect(response).to match("-- Request apostrophe's data --")
    end

    it "does not add HTMLEntities to the public body name" do
      result = { :model => event }
      assign(:email_about_things, [[track, [result], xapian_search]])
      render
      expect(response).to match("request to Apostrophe's")
    end

    it "does not add HTMLEntities to the user name" do
      result = { :model => event }
      assign(:email_about_things, [[track, [result], xapian_search]])
      render
      expect(response).to match("Test Us'r sent a request")
    end
  end

  it "does not add HTMLEntities to the site name" do
    assign(:user, user)
    assign(:email_about_things, [])
    render
    expect(response).to match("the l'Information team")
  end
end
