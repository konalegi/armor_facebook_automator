require 'test_helper'

class FacebookServiceTest < ActiveSupport::TestCase

  test 'should perform job' do
    service = FacebookService.new()
    service.perform
  end

end