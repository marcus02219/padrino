module DreamWalk
  module Padrino
    module Api

      def self.registered(app)

        # load api helpers
        app.helpers Helpers

        # set default app options
        app.disable :sessions
        app.disable :protect_from_csrf
        app.enable :api_authentication

        # disable api authentication in dev and test environments
        if [:development, :test].include?(app.environment)
          app.disable :api_authentication
        end

        # executed before all controller actions
        app.before do
          content_type :json
          ensure_valid_user_token_if_present
          ensure_valid_request_signature(app.session_secret) if app.api_authentication
          headers 'Date' => DateTime.now.rfc822
        end

      end

      module Helpers

        def json_params
          if @json_params.nil?
            begin
              @json_params = Oj.load(request.body, symbol_keys: true)
            rescue ArgumentError, Oj::ParseError => e
              # fail silently
            end
          end
          @json_params || {}
        end

        def api_params
          @merged_params ||= params.reject{ |k,v| k[0] == "{" }.symbolize_keys.merge(json_params)
        end

        def ensure_valid_user_token_if_present
          token_id = api_params[:api_user_token]
          if token_id.present?
            @api_user_token = ApiUserToken[token_id]
            halt_with_session_expired_error unless @api_user_token.present?
          else
            @api_user_token = nil
          end
        end

        def ensure_valid_request_signature(secret)
          authorised = ApiRequest.authorised?(request.env["HTTP_AUTHORIZATION"], secret, @api_user_token)
          halt_with_not_authorised_error unless authorised
        end

        def ensure_valid_user_token
          halt_with_not_authenticated_error unless @api_user_token.present?
        end

        def ensure_token_belonging_to_user(user_id)
          ensure_valid_user_token
          halt_with_not_authorised_error unless @api_user_token.user_id.to_s == user_id.to_s
        end

        def ensure_user_not_logged_in
          halt_with_already_logged_in_error if @api_user_token.present?
        end

        def ensure_required_params(required_params = [])
          missing_params = required_params.reject{ |param| api_params[param].present? }
          halt_with_missing_parameters_error_for(missing_params) if missing_params.present?
        end

        def ensure_passed_params(passed_params = [])
          missing_params = passed_params.reject{ |param| api_params.key?(param) }
          halt_with_missing_parameters_error_for(missing_params) if missing_params.present?
        end

        def api_user_id
          @api_user_token.present? ? @api_user_token.user_id : nil
        end

        def api_user
          @api_user_token.present? ? @api_user_token.user : nil
        end

        def api_modified_since
          begin
            Time.rfc822(request.env['HTTP_IF_MODIFIED_SINCE'])
          rescue ArgumentError => e
            nil
          end
        end

        def halt_with_client_error
          halt 400, Oj.dump({ "dw_api_error_client" => "An unknown client error has occurred. Try again in a few seconds; if the problem persists, please contact us." })
        end

        def halt_with_already_logged_in_error
          halt 400, Oj.dump({ "dw_api_error_already_logged_in" => "You are already signed in." })
        end

        def halt_with_missing_parameters_error_for(m)
          halt 400, Oj.dump({ "dw_api_error_missing_parameters" => "Required parameters missing: #{ m.join(', ') }" })
        end

        def halt_with_validation_errors(e)
          halt 400, Oj.dump({ dw_api_error_validation: e }, mode: :compat)
        end

        def halt_with_not_authenticated_error
          halt 401, Oj.dump({ "dw_api_error_not_authenticated" => "You must be signed in to do this." })
        end

        def halt_with_session_expired_error
          halt 401, Oj.dump({ "dw_api_error_not_authenticated" => "Your session has expired. Please sign in again." })
        end

        def halt_with_not_authorised_error
          halt 403, Oj.dump({ "dw_api_error_not_authorised" => "You do not have permission to do this." })
        end

        def halt_with_not_found_error
          halt 404, Oj.dump({ "dw_api_error_not_found" => "The content you tried to access is unavailable." })
        end

        def halt_with_server_error
          halt 500, Oj.dump({ "dw_api_error_server" => "An unknown server error has occurred. Try again in a few seconds; if the problem persists, please contact us." })
        end

      end

    end
  end
end
