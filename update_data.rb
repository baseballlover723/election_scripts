require 'json'
require 'httparty'

URL = 'https://static01.nyt.com/elections-assets/2020/data/api/2020-11-03/national-map-page/national/president.json'
TRUMP_KEY = "trumpd"
BIDEN_KEY = "bidenj"
THRESHOLD = 95

def main()
  state_slugs = ARGV.map(&:downcase)
  master_json = HTTParty.get(URL).parsed_response
  master_json["data"]["races"].filter do |json|
    state_slugs.include?(json["state_slug"])
  end.each do |state_json|
    update_state(state_json)
  end
end

def update_state(json)
  slug = json["state_slug"]
  puts "updating state: #{slug}"
  biden_current_total = total(json, BIDEN_KEY)
  trump_current_total = total(json, TRUMP_KEY)
  counties = json["counties"].filter { |county| county["eevp"] <= THRESHOLD }.map do |county|
    {name: county["name"],
     biden: county["results"][BIDEN_KEY] / 1_000.0,
     trump: county["results"][TRUMP_KEY] / 1_000.0,
     perc: county["votes"].to_f / county["tot_exp_vote"].to_f
    }
  end
  data = {
    name: json["state_name"],
    biden: biden_current_total / 1_000.0,
    trump: trump_current_total / 1_000.0,
    counties: counties
  }
  File.write("#{slug}.json", JSON.pretty_generate(data))
end

def total(json, key)
  json["candidates"].filter { |c| c["candidate_key"] == key }[0]["votes"]
end

def sum_total(json, key)
  json["counties"].sum do |county|
    county["results"][key] + county["results_absentee"][key]
  end
end

main
