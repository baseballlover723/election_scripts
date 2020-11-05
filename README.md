# election_scripts
calculates how if biden is likely to get enough votes given some county data

to use run
`bundle install`

examples usage

To calculate: `ruby election.rb georgia`

To update data: `ruby update_data.rb georgia north-carolina pennsylvania nevada arizona`

update and run: `ruby update_data.rb georgia north-carolina pennsylvania nevada arizona && ruby election.rb pennsylvania`
