# PLEASE DO NOT CONSIDER THIS BEST PRACTICES FOR BUILDING TESTS
# BUT WILL HELP US GET SOME TESTS WRITTEN QUICKLY WHICH IS BETTER
# THAN NO TESTS

desc 'Create YAML test fixtures from data in an existing database.
Defaults to development database.  Set RAILS_ENV to override.'

task :extract_fixtures => :environment do
  sql  = "SELECT * FROM %s"
  skip_tables = ["schema_info"]
  ActiveRecord::Base.establish_connection
  (ActiveRecord::Base.connection.tables - skip_tables).each do |table_name|
    i = "000"
    File.open("#{Rails.root}/test/fixtures/#{table_name}.yml", 'w') do |file|
      data = ActiveRecord::Base.connection.select_all(sql % table_name)
      file.write data.inject({}) { |hash, record|
        hash["#{table_name}_#{i.succ!}"] = record
        hash
      }.to_yaml
    end
  end
end
