require 'rubygems'
require 'bundler/setup'
Bundler.require

require_relative "client"

CSV.open("ca_district_results.csv", "wb") do |district_results|
  district_results << %w(district_name office_title district_type district_locale_name zip state)
  district_results.flush
  CSV.foreach("ca_zips.csv", headers: true) do |row|
    GoogleCivicInfoClient.new.representative_info("#{row["state"]}, #{row["zip"]}").each  do |district|
      district_results << district.push(row["zip"], row["state"])
      district_results.flush
    end
  end
end
