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
      end

      def retrieve_and_save
        db.execute 'BEGIN TRANSACTION'
        retrieve.each do |hash|
          insert(hash)
        end
        db.execute 'COMMIT'
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
          hash[:postcode],
          hash[:prefecture], hash[:prefecture_kana], hash[:prefecture_code],
          hash[:city], hash[:city_kana],
          hash[:town], hash[:town_kana],
          hash[:street],
          hash[:office_name],
          hash[:office_name_kana]
        )
      end
    end
  end
end
