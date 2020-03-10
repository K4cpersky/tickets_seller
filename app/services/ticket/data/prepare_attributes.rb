# frozen_string_literal: true

class Ticket::Data::PrepareAttributes
  def self.call(tickets_number:, ticket_payment_id:)
    tickets = []
    tickets_number.times { tickets << { payment_id: ticket_payment_id } }
    tickets
  end
end