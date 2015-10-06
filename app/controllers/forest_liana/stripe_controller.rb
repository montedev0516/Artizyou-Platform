module ForestLiana
  class StripeController < ForestLiana::ApplicationController

    def payments
      getter = StripePaymentsGetter.new(params,
                                        request.headers['Stripe-Secret-Key'],
                                        request.headers['Stripe-Reference'])
      getter.perform

      render json: serialize_models(getter.records, {
        count: getter.count,
        include: ['customer']
      })
    end

    def refund
      begin
        refunder = StripePaymentRefunder.new(params)
        refunder.perform

        render json: {}
      rescue Stripe::InvalidRequestError => err
        render json: { error: err.message }, status: 400
      end
    end

    def cards
      getter = StripeCardsGetter.new(params,
                                     request.headers['Stripe-Secret-Key'],
                                     request.headers['Stripe-Reference'])
      getter.perform

      render json: serialize_models(getter.records, {
        count: getter.count,
        include: ['customer']
      })
    end

    def invoices
      getter = StripeInvoicesGetter.new(params,
                                        request.headers['Stripe-Secret-Key'],
                                        request.headers['Stripe-Reference'])
      getter.perform

      render json: serialize_models(getter.records, {
        count: getter.count,
        include: ['customer']
      })
    end

  end
end
