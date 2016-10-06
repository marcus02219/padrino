module Request
  module Helpers
    def json
      @json ||= Oj.load(last_response.body)
    end
    def json_pretty
      @json_pretty ||= Oj.dump(json, indent: 2)
    end
    def json_raw
      @json_raw ||= last_response.body
    end
    def json_at(path = "")
      parse_json(json_raw, path)
    end
  end
end

RSpec::Matchers.define :be_user_required_response do
  match do
    expect(last_response.status).to eq 401
    expect(last_response.body).to match(/dw_api_user_token_required/)
  end
  failure_message do |actual|
    "expected a user required response, got:\n#{ Oj.dump(actual, indent: 2) }"
  end
end

RSpec::Matchers.define :be_not_authorised_response do
  match do
    expect(last_response.status).to eq 403
    expect(last_response.body).to match(/not_authorised/)
  end
  failure_message do |actual|
    "expected a not authorised response, got:\n#{ Oj.dump(actual, indent: 2) }"
  end
end

RSpec::Matchers.define :be_already_logged_in_response do
  match do
    expect(last_response.status).to eq 400
    expect(last_response.body).to match(/already_logged_in/)
  end
  failure_message do |actual|
    "expected a already logged in response, got:\n#{ Oj.dump(actual, indent: 2) }"
  end
end

RSpec::Matchers.define :be_missing_parameters_response do
  match do
    expect(last_response.status).to eq 400
    expect(last_response.body).to match(/dw_api_required_parameters_missing/)
  end
  failure_message do |actual|
    "expected a missing parameters response, got:\n#{ Oj.dump(actual, indent: 2) }"
  end
end
RSpec::Matchers.define :be_missing_parameters_response_for do |missing_params|
  match do
    expect(last_response).to be_missing_parameters_response
    missing_params.each do |missing_param|
      expect(last_response.body).to match(Regexp.new(missing_param))
    end
  end
  failure_message do |actual|
    "expected a missing parameters response for #{ missing_params.join(', ') }, got:\n#{ Oj.dump(actual, indent: 2) }"
  end
end

RSpec::Matchers.define :be_validation_errors_response do
  match do
    expect(last_response.status).to eq 400
    expect(last_response.body).to match(/validation_errors/)
  end
  failure_message do |actual|
    "expected validation errors response, got:\n#{ Oj.dump(actual, indent: 2) }"
  end
end
RSpec::Matchers.define :be_validation_errors_response_for do |invalid_params|
  match do
    expect(last_response).to be_validation_errors_response
    invalid_params.each do |invalid_param|
      expect(last_response.body).to match(Regexp.new(invalid_param))
    end
  end
  failure_message do |actual|
    "expected validation errors response for #{ invalid_params.join(', ') }, got:\n#{ Oj.dump(actual, indent: 2) }"
  end
end