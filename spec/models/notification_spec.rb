# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: notifications
#
#  id                    :integer          not null, primary key
#  info_request_event_id :integer          not null
#  user_id               :integer          not null
#  frequency             :integer          default(0), not null
#  seen_at               :datetime
#  send_after            :datetime         not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#

require "spec_helper"

RSpec.describe Notification do
  it "requires an info_request_event" do
    notification = FactoryGirl.build(:notification,
                                     info_request_event: nil,
                                     user: FactoryGirl.create(:user))
    expect(notification).not_to be_valid
  end

  it "requires a user" do
    notification = FactoryGirl.build(:notification, user: nil)
    expect(notification).not_to be_valid
  end

  it "requires a frequency" do
    notification = FactoryGirl.build(:notification, frequency: nil)
    expect(notification).not_to be_valid
  end

  describe "setting send_after" do
    context "when frequency is 'instantly'" do
      let(:notification) { FactoryGirl.create(:instant_notification) }

      it "sets send_after to Time.zone.now" do
        expect(notification.send_after).to be_within(1.second).of(Time.zone.now)
      end
    end

    context "when the frequency is 'daily'" do
      let(:user) { FactoryGirl.create(:user) }
      let(:notification) do
        FactoryGirl.create(:daily_notification, user: user)
      end
      let(:user_time) { expected_time = Time.zone.now + 3.hours }

      before do
        allow(user).to receive(:next_daily_summary_time).and_return(user_time)
      end

      it "sets send_after to the user's next daily summary time" do
        expect(notification.send_after).to be_within(1.second).of(user_time)
      end
    end

    context "when the notification has already been created" do
      let(:notification) { FactoryGirl.create(:instant_notification) }
      let(:new_time) { expected_time = Time.zone.now + 3.hours }

      it "doesn't recalculate the send_after" do
        notification.send_after = new_time
        notification.save!
        expect(notification.send_after).to be_within(1.second).of(new_time)
      end
    end

    context "when the send_after time is set manually during creating" do
      let(:delayed_time) { expected_time = Time.zone.now + 3.hours }
      let(:notification) do
        FactoryGirl.create(:instant_notification, send_after: delayed_time)
      end

      it "doesn't overwrite it" do
        expect(notification.send_after).to be_within(1.second).of(delayed_time)
      end
    end
  end

  describe ".unseen" do
    let!(:unseen_notification) do
      FactoryGirl.create(:notification, seen_at: nil)
    end
    let!(:seen_notification) do
      FactoryGirl.create(:notification, seen_at: Time.zone.now)
    end

    it "only returns unseen notifications" do
      expect(Notification.unseen).to match_array([unseen_notification])
    end
  end
end
