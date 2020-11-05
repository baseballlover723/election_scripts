require "colorize"
require "json"
def main()
  json = JSON.parse(File.read("#{ARGV[0]}.json"))
  name = json["name"]
  current_biden_state = json["biden"]
  current_trump_state = json["trump"]
  current_biden_diff = current_trump_state - current_biden_state
  counties = json["counties"]
  puts "biden currently needs #{current_biden_diff.round(3)}K votes to win in #{name}"
  county_diffs = {}
  counties.each do |county|
    county_diffs[county["name"]] = calc_county(county["biden"], county["trump"], county["perc"])
  end
  county_diffs = county_diffs.sort_by {|_key, value| -value}.to_h

  biden_diff = county_diffs.values.sum
  county_diffs_str = county_diffs.map{|k, v| [k, v > 0 ? "#{v.round(3)}K".light_green : "#{v.round(3).abs}K".light_red] }.to_h
  avg = biden_diff / counties.size

  puts "counties data considered: #{unescape_str(JSON.generate(county_diffs_str))}}"
  puts "biden expected to get #{biden_diff.round(3)}K more votes over #{counties.size} counties (#{avg.round(3)}K per county avg)"
  puts get_str(current_biden_diff, biden_diff)
end

def calc_county(current_biden, current_trump, perc_reporting)
  calc_total(current_biden, perc_reporting) - calc_total(current_trump, perc_reporting)
end

def calc_total(current, perc)
  (current / perc) - current
end

def get_str(current_biden_diff, biden_diff)
  diff_diff = biden_diff - current_biden_diff
  has_enough = diff_diff > 0
  numb_str = "#{diff_diff.abs.round(3)}K"
  numb_str = has_enough ? numb_str.light_green : numb_str.light_red

  "Thats #{numb_str} #{has_enough ? "more" : "less"} then biden needs"
end

def unescape_hash(h)
  eval("\"#{h.to_s.gsub('"', '\"')}\"")
end

def unescape_str(str)
  eval("\"#{str.gsub('"', '\"')}\"")
end

main
