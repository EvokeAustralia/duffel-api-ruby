# frozen_string_literal: true

require "duffel_api"

client = DuffelAPI::Client.new(
  access_token: ENV["DUFFEL_ACCESS_TOKEN"],
)

offer_request = client.offer_requests.create(params: {
  cabin_class: "economy",
  passengers: [{
    age: 28,
  }],
  slices: [{
    origin: "LHR",
    destination: "NYC",
    departure_date: "2022-12-31",
  }],
  # This attribute is sent as a query parameter rather than in the body like the others.
  # Worry not! The library handles this complexity for you.
  return_offers: false,
})

puts "Created offer request: #{offer_request.id}"

offers = client.offers.all(params: { offer_request_id: offer_request.id })

puts "Got #{offers.length} offers"

selected_offer = offers.first

puts "Selected offer #{offer.id} to book"

priced_offer = client.offers.get(selected_offer.id)

puts "The final price for offer #{offer.id} is #{offer.total_amount} " \
     "#{offer.total_currency}"

order = client.orders.create(params: {
  selected_offers: [priced_offer.id],
  payments: [
    {
      type: "balance",
      amount: priced_offer.total_amount,
      currency: priced_offer.total_currency,
    },
  ],
  passengers: [
    {
      id: priced_offer.passengers.first.id,
      given_name: "Tim",
      family_name: "Rogers",
      born_on: "1993-04-01",
      phone_number: "+441290211999",
      email: "tim@duffel.com",
    },
  ],
})

puts "Created order #{order.id} with booking reference #{order.booking_reference}"
