list = []
data = File.read("README.md")
data.split("\n#").each do |section|
  entries = section.split("\n*")
  section_name = entries.shift.gsub("#", "").strip
  entries.each do |entry|
    match_data = entry.match(/\[(?<name>.+?)\]\((?<url>.+?)\)(.+\[GitHub\]\((?<github>.+?)\)\))?\s+(-\s+)?(?<description>.+)/)
    list << {
      section: section_name,
      name: match_data[:name],
      url: match_data[:url],
      github: match_data[:github],
      description: match_data[:description],
    }
  end
end


toml = list.sort { |a, b| a[:name] <=> b[:name] }.map do |entry|
  out = "[[company]]\n"
  out << %Q[name = "#{entry[:name]}"\n]
  out << %Q[section = "#{entry[:section]}"\n]
  out << %Q[url = "#{entry[:url]}"\n]
  out << %Q[github = "#{entry[:github]}"\n]
  out << %Q[description = "#{entry[:description]}"\n]
end.join("\n")

File.open("elixir-companies.toml", "w") { |f| f.write(toml) }