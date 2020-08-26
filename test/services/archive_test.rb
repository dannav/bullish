
require './test/test_helper'
require './services/archive'
require 'aws-sdk-s3'
require './services/s3'

module Services
  class ArchiveTest < Minitest::Test
    def test_upload
      mock = MiniTest::Mock.new

      params = [
        "#{Services::Archive::FOLDER}/nasdaq-is-up-2.html", 
        "Content", 
        {:subject_base64=>"TmFzZGFxIGlzIHVwIDIl"}
      ]

      mock.expect(:upload, nil, params)

      Services::S3.stub :new, mock do
        Services::Archive.new.upload('Nasdaq is up 2%', 'Content')
      end

      mock.verify
    end

    def test_build_index
      # p Services::S3.new('bullish-archive').list

      # Services::Archive.new.upload('S&P 500 rose 0.32% 👍 today', 'content blabla')

      # Services::Archive.new.build_directory
    end
  end
end
