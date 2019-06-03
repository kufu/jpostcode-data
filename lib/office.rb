require 'zip'
require 'nokogiri'
require 'open-uri'
require 'csv'
require 'nkf'
require_relative 'base'

module Jpostcode
  module Data
    class Office < Base

      private

      ZIP_URL = 'https://www.post.japanpost.jp/zipcode/dl/jigyosyo/zip/jigyosyo.zip'

      SELECT_SQL = <<-SQL
        SELECT
          prefecture_kana,
          prefecture_code,
          city_kana,
          town_kana
        FROM
          addresses
        WHERE
          prefecture = ?
        AND city = ?
        AND town = ?
        LIMIT 1
      SQL

      def to_hash(row)
        {
          postcode:         row[7],
          prefecture:       NKF.nkf('-S -w', row[3]),
          city:             NKF.nkf('-S -w', row[4]),
          town:             NKF.nkf('-S -w', row[5]),
          street:           NKF.nkf('-S -w', row[6]),
          office_name:      NKF.nkf('-S -w', row[2]),
          office_name_kana: NKF.nkf('-S -w', row[1])
        }
      end

      def retrieve
        arr = []
        Zip::File.open(open(ZIP_URL).path) do |archives|
          archives.each do |a|
            CSV.parse(a.get_input_stream.read) do |row|
              h = to_hash(row)
              h[:town] = '永山北２条' if h[:town] == '永山北二条'

              h[:prefecture_kana],
              h[:prefecture_code],
              h[:city_kana],
              h[:town_kana] = db.execute(SELECT_SQL, h[:prefecture], h[:city], h[:town]).first

              arr << h
            end
          end
        end
        arr
      end
    end
  end
end
