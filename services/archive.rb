# frozen_string_literal: true

require './services/s3'
require 'base64'
require 'date'
require './templates/element'
require 'active_support/inflector'

module Services
  class Archive
    YEAR = Time.now.year
    MONTH = Time.now.month

    FOLDER = "#{YEAR}-#{MONTH}"
    BUCKET = 'bullish-archive'
    MONTH_YEAR_FORMAT = '%B %Y'

    def upload(subject, content)
      # create friendly URL
      name = subject.parameterize.dasherize

      name = "#{FOLDER}/#{name}.html"
      tags = { subject_base64: Base64.urlsafe_encode64(subject, padding: false) }

      Services::S3.new(BUCKET).upload(name, content, tags)
    end

    def build_index
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

      heading = DateTime.now.strftime(MONTH_YEAR_FORMAT)
      result = Templates::Element.render('archive', { archive: archive, heading: heading })

      # save in archive root path
      s3.upload('index.html', result)

      # copy to folder so each month has an index
      s3.copy('index.html', "#{FOLDER}/index.html")
    end

    def build_directory
      s3 = Services::S3.new(BUCKET)

      index = s3.list_folders.map do |folder|
        # format folder like 2020-8 to August 2020
        title = Date.strptime(folder, '%Y-%m').strftime(MONTH_YEAR_FORMAT)

        { url: "/archive/#{folder}", title: title }
      end

      result = Templates::Element.render('archive_index', { index: index })

      # save in archive root path
      s3.upload('directory.html', result)
    end
  end
end
