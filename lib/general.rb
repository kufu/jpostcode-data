require 'zip'
require 'nokogiri'
require 'csv'
require 'nkf'
require 'yaml'
require_relative 'base'

module Jpostcode
  module Data
    class General < Base
      private

      URL_DOMAIN = 'http://zipcloud.ibsnet.co.jp'

      def to_hash(row)
        {
          postcode:        row[2],
          prefecture:      NKF.nkf('-S -w', row[6]),
          prefecture_kana: NKF.nkf('-S -w', row[3]),
          city:            NKF.nkf('-S -w', row[7]),
          city_kana:       NKF.nkf('-S -w', row[4]),
          town:            NKF.nkf('-S -w', row[8]),
          town_kana:       NKF.nkf('-S -w', row[5])
        }
      end

      def retrieve
        arr = []
        Zip::File.open(URI.open(zip_url).path) do |archives|
          archives.each do |a|
            CSV.parse(a.get_input_stream.read) do |row|
              h = to_hash(row)
              h[:prefecture_code] = prefecture_codes.invert[h[:prefecture]]
              arr << h
            end
          end
        end
        arr
      end

      def prefecture_codes
        @prefecture_codes ||= YAML.safe_load(File.open(File.expand_path('../prefecture_code.yml', __FILE__)))
      end

      def zip_url
        html = Nokogiri::HTML(URI.open(URL_DOMAIN))
        url = html.css('[href^="/zipcodedata/download"]').last.attributes['href']
        "#{URL_DOMAIN}#{url}"
      end
    end
  end
end
