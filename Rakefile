require_relative 'lib/general'
require_relative 'lib/office'
require_relative 'lib/exporter'

namespace :jpostcode do
  namespace :data do
    desc 'Updates postcode data'
    task :update_all do
      # puts 'Reset temp DB...'
      # general = Jpostcode::Data::General.new
      # general.reset_table
      #
      # puts 'Retrieveing general zip data...'
      # general.retrieve_and_save
      #
      # puts 'Retrieveing office zip data...'
      # office = Jpostcode::Data::Office.new
      # office.retrieve_and_save

      puts 'Extract to json files...'
      Jpostcode::Data::Exporter.new.execute
    end
  end
end
