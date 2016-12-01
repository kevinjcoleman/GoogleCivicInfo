class GoogleCivicInfoClient
  include HTTParty
  base_uri 'https://www.googleapis.com/civicinfo/v2/'
  attr_accessor :token, :response, :divisions, :results

  BLACKLISTED_OFFICES = %w(cd country state sldu sldl)

  def initialize
    @token = ENV["GOOGLE_API_KEY"]
    @results = []
  end

  def representative_info(address)
    @response = self.class.get("/representatives", merge_query({address: address}))
    remove_blacklisted_divisions
    list_offices
    results
  end

  def list_offices
    return if divisions.nil?
    divisions.each do |divisionName, officeIndices|
      next if officeIndices.nil?
      officeIndices.each do |index|
        office = response["offices"][index]
        @results << [divisionName,
                     office_name(office),
                     office_type(office),
                     office_locale(office)]
      end
    end
  end

  def remove_blacklisted_divisions
    return if response["divisions"].nil?
    @divisions = response["divisions"].each_with_object({}) do |division, results|
      next if BLACKLISTED_OFFICES.include?(district_type(division.first))
      results[division.last["name"]] = division.last["officeIndices"]
    end
  end

  def district_type(districtKey)
    districtKey.split("/").last.split(":").first
  end

  def office_type(office)
    office["divisionId"].split("/").last.split(":").first
  end

  def office_locale(office)
    office["divisionId"].split("/").last.split(":").last
  end

  def office_name(office)
    office["name"]
  end

  private
    def merge_query(query)
      {query: query.merge({key: token})}
    end
end
