# frozen_string_literal: true

require 'rails_helper'
require 'json'

RSpec.describe Payment::Process do
  describe '.call' do
    subject(:call) { described_class.call(payment_params) }

    let!(:event) do
      create(
        :event,
        ticket_price: 10,
        tickets_available: tickets_available,
        tickets_amount: tickets_amount,
        happens_at: happens_at
      )
    end
    let!(:user) { create(:user) }

    let(:payment_params) do
      {
        user_id: user.id,
        event_id: event.id,
        paid_amount: 40,
        tickets_ordered_amount: tickets_ordered_amount,
        currency: 'EUR'
      }
    end
    let(:tickets_ordered_amount) { 4 }
    let(:tickets_available) { 1000 }
    let(:tickets_amount) { 1000 }
    let(:happens_at) { 1.week.from_now }
    let(:payment) do
      build(:payment,
            user_id: payment_params[:user_id],
            event_id: payment_params[:event_id],
            paid_amount: payment_params[:paid_amount],
            tickets_ordered_amount: payment_params[:tickets_ordered_amount],
            currency: payment_params[:currency])
    end

    it 'calls payment create form' do
      expect(Payments::CreateForm)
        .to receive(:new)
        .with(payment_params)
        .and_return(payment)
        .and_call_original

      call
    end

    it 'submits payment form' do
      expect_any_instance_of(Payments::CreateForm)
        .to receive(:submit)
        .and_call_original

      call
    end

    it 'create tickets' do
      # TODO: How should I know what will be id of payment? It's 3 but should be assigned to sth.
      expect(Ticket::Generate)
        .to receive(:call)
        .with(tickets_ordered_amount: tickets_ordered_amount, payment_id: 3)
        .and_call_original

      call
    end

    it 'updates event amount of available tickets' do
      # TODO: How should I know what will be id of payment? It's 4 but should be assigned to sth.
      expect(Event::UpdateAvailableTickets)
        .to receive(:call)
        .with(4)
        .and_call_original

      call
    end

    it 'returns payment data' do
      call
      expect(call.new_payment.paid_amount).to eq payment_params[:paid_amount]
      expect(call.new_payment.user_id).to eq user.id
      expect(call.new_payment.event_id).to eq event.id
      expect(call.new_payment.currency).to eq payment_params[:currency]
      expect(call.new_payment.tickets_ordered_amount)
        .to eq payment_params[:tickets_ordered_amount]
    end
  end
end
