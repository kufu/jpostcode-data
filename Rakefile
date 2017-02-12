require_relative 'lib/general'
require_relative 'lib/office'
require_relative 'lib/exporter'

namespace :postcode_jp do
  desc 'Updates postcode data'
  task :update_all do
    # puts 'Reset temp DB...'
    # general = PostcodeJp::General.new
    # general.reset_table
    #
    # puts 'Retrieveing general zip data...'
    # general.retrieve_and_save
    #
    # puts 'Retrieveing office zip data...'
    # office = PostcodeJp::Office.new
    # office.retrieve_and_save

    puts 'Extract to json files...'
    PostcodeJp::Exporter.new.execute
  end
end
