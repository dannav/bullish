
require './test/test_helper'
require './services/archive'
require 'aws-sdk-s3'
require './services/s3'

module Services
  class ArchiveTest < Minitest::Test
    def test_list
      # p Services::S3.new('bullish-archive').list

      # Services::Archive.new.upload('S&P 500 rose 0.32% 👍 today', 'content blabla')

      Services::Archive.new.build
    end
  end
end
