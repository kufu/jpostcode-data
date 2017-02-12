require 'json'
require 'pry'
require_relative 'base'

module PostcodeJp
  class Exporter
    SELECT_SQL = <<-SQL
      SELECT
        postcode,
        prefecture, prefecture_kana, prefecture_code,
        city, city_kana,
        town, town_kana,
        street,
        office_name,
        office_name_kana
      FROM addresses
      ORDER BY postcode
    SQL

    def initialize
      @db = PostcodeJp::Base.new.db
    end

    def execute
      postcodes.each do |prefix, value|
        file_path = File.expand_path("../../data/json/#{prefix}.json", __FILE__)
        File.open(file_path, 'wb') do |file|
          file.write JSON.pretty_generate(value)
        end
      end
    end

    private

    def postcodes
      ret = {}

      @db.execute(SELECT_SQL) do |row|
        h = {}
        h[:postcode],
        h[:prefecture],
        h[:prefecture_kana],
        h[:prefecture_code],
        h[:city],
        h[:city_kana],
        h[:town],
        h[:town_kana],
        h[:street],
        h[:office_name],
        h[:office_name_kana] = row

        first_prefix  = h[:postcode].slice(0, 3)
        second_prefix = h[:postcode].slice(3, 4)
        ret[first_prefix] ||= {}

        if ret[first_prefix][second_prefix] && !ret[first_prefix][second_prefix].instance_of?(Array)
          ret[first_prefix][second_prefix] = [ret[first_prefix][second_prefix]]
        end

        if ret[first_prefix][second_prefix].instance_of?(Array)
          ret[first_prefix][second_prefix].push h
        else
          ret[first_prefix] = ret[first_prefix].merge(second_prefix => h)
        end
      end

      ret
    end
  end
end
