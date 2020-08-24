# frozen_string_literal: true

require './services/s3'
require 'base64'
require 'date'
require './templates/element'
require 'active_support/inflector'

module Services
  class Archive
    # save in S3 by year then month
    # one main index.html as archive root with current month
    # every new month archive root index in its month
    # generate an archive index ordered by date pulling folders from s3 / will hit index in each month

    YEAR = Time.now.year
    MONTH = Time.now.month

    FOLDER = "#{YEAR}-#{MONTH}"
    BUCKET = 'bullish-archive'

    def upload(subject, content)
      # create friendly URL
      name = subject.parameterize.dasherize

      name = "#{FOLDER}/#{name}.html"
      tags = { subject_base64: Base64.urlsafe_encode64(subject, padding: false) }

      Services::S3.new(BUCKET).upload(name, content, tags)
    end

    def build
      s3 = Services::S3.new(BUCKET)

      archive = s3.list({ prefix: FOLDER }).map do |file|
        next if file.key == "#{FOLDER}/index.html"

        tags = s3.tags(file.key)

        title = Base64.urlsafe_decode64(tags['subject_base64'])

        {
          url: "/archive/#{file.key}",
          title: title,
          date: DateTime.parse(file.last_modified.to_s).strftime('%A %d')
        }
      end.compact

      heading = DateTime.now.strftime('%B %Y')
      result = Templates::Element.render('archive', { archive: archive, heading: heading })

      # save in archive root path
      s3.upload('index.html', result)

      # copy to folder so each month has an index
      s3.copy('index.html', "#{FOLDER}/index.html")
    end
  end
end
