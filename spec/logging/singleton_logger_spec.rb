require 'spec_helper'

include Proxy::Logging

describe SimpleLogger do
  context 'is a singleton when called' do
    it 'two times' do
      first_logger = logger.__id__
      second_logger= logger.__id__

      expect(first_logger).to eq(second_logger)
    end

    it 'from two classes' do
      first_logger = LoggingCaller.new.logger_test.__id__
      second_logger = LoggingCaller.new.logger_test.__id__

      expect(first_logger).to eq(second_logger)
    end

    it 'from two requests' do
      get 'http://www.google.ch'
      first_id = last_request.env['proxy.logger_id']
      get 'http://www.lemonde.fr'
      second_id = last_request.env['proxy.logger_id']

      expect(first_id).to eq(second_id)
    end
  end


end