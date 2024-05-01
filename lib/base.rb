require 'sqlite3'

module Jpostcode
  module Data
    class Base
      def db
        @db ||= SQLite3::Database.new('tmp/test.db')
      end

      def reset_table
        drop_table
        create_table
      end

      def drop_table
        db.execute <<-SQL
          DROP TABLE IF EXISTS addresses;
        SQL
      end

      def create_table
        db.execute <<-SQL
          CREATE TABLE addresses (
            postcode VARCHAR(7),
            prefecture VARCHAR(256),
            prefecture_kana VARCHAR(256),
            prefecture_code INTEGER,
            city VARCHAR(256),
            city_kana VARCHAR(256),
            town VARCHAR(256),
            town_kana VARCHAR(256),
            street VARCHAR(256),
            office_name VARCHAR(256),
            office_name_kana VARCHAR(256)
          );
        SQL

        db.execute <<-SQL
          CREATE INDEX idx_addresses ON addresses (prefecture, city, town);
        SQL
      end

      def retrieve_and_save
        db.execute 'BEGIN TRANSACTION'
        retrieve.each do |hash|
          insert(hash)
        end
        db.execute 'COMMIT'
      end

      def convert_kansuji(text)
        return text if text.nil?

        text.tr('〇一二三四五六七八九', '0123456789')
          .gsub(/(\d+)?十(\d+)?/) { ($1 || 1).to_i * 10            + $2.to_i }
          .gsub(/(\d+)?百(\d+)?/) { ($1 || 1).to_i * 100           + $2.to_i }
          .gsub(/(\d+)?千(\d+)?/) { ($1 || 1).to_i * 1000          + $2.to_i }
          .gsub(/(\d+)万(\d+)?/)  {        $1.to_i * 10000         + $2.to_i }
          .gsub(/(\d+)億(\d+)?/)  {        $1.to_i * 100000000     + $2.to_i }
          .gsub(/(\d+)兆(\d+)?/)  {        $1.to_i * 1000000000000 + $2.to_i }
      end

      def convert_to_zen(text)
        text.tr('0-9', '０-９')
      end

      INSERT_SQL = <<-SQL
        INSERT INTO addresses (
          postcode,
          prefecture, prefecture_kana, prefecture_code,
          city, city_kana,
          town, town_kana,
          street,
          office_name,
          office_name_kana
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
      SQL

      private

      def insert(hash)
        db.execute(
          INSERT_SQL,
          [
            hash[:postcode],
            hash[:prefecture], hash[:prefecture_kana], hash[:prefecture_code],
            hash[:city], hash[:city_kana],
            hash[:town], hash[:town_kana],
            hash[:street],
            hash[:office_name],
            hash[:office_name_kana]
          ]
        )
      end
    end
  end
end
