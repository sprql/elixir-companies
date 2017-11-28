defmodule ElixirCompanies.ReadmeParser do
  @regexp_with_url ~r/\A\s*\[(?<name>.+?)\]\((?<url>.+?)\)\s(\[blog\]\((?<blog>.+?)\)\)\s)?(\(\[github\]\((?<github>.+?)\)\)\s)?(-\s+)?(?<description>.+)/ims
  @regexp_without_url ~r/\A\s*(?<name>.+?)\s(\[blog\]\((?<blog>.+?)\)\)\s)?(\(\[github\]\((?<github>.+?)\)\)\s)?(-\s+)?(?<description>.+)/ims

  def parse(markdown) do
    data =
      markdown
      |> strip_header_and_footer()
      |> String.split("\n##")

    Enum.flat_map(data, fn section ->
      [section_name | entries] = String.split(section, ~r/\n(\*|\+)/)
      section_name = format_section_name(section_name)
      Enum.map(entries, &parse_entry(&1, section_name))
    end)
  end

  defp strip_header_and_footer(markdown) do
    markdown
    |> String.replace(~r/^.+?#/, "")
    |> String.replace(~r/## Contributing.+$/, "")
  end

  defp format_section_name(string) do
    string
    |> String.replace("#", "")
    |> String.trim()
  end

  defp parse_entry(entry, section_name) do
    match_data =
      Regex.named_captures(@regexp_with_url, entry) ||
        Regex.named_captures(@regexp_without_url, entry)

    description =
      match_data["description"]
      |> String.replace("\n", " ")
      |> String.replace(~r/\s+/, " ")
      |> String.trim()

    match_data
    |> Map.put("section", section_name)
    |> Map.put("description", description)
  end
end

defmodule ElixirCompanies.TomlBuilder do
  def build(list) do
    list
    |> Enum.sort_by(& &1["name"])
    |> Enum.map(&format_company(&1))
    |> Enum.join("\n")
  end

  defp format_company(entry) do
    "[[company]]\n" <>
      format(entry, "name") <>
      format(entry, "section") <>
      format(entry, "url") <>
      format(entry, "blog") <> format(entry, "github") <> format(entry, "description")
  end

  defp format(entry, key) do
    cond do
      entry[key] && entry[key] != "" -> ~s/#{key} = "#{entry[key]}"\n/
      true -> ""
    end
  end
end

toml =
  File.read!("README.md")
  |> ElixirCompanies.ReadmeParser.parse()
  |> ElixirCompanies.TomlBuilder.build()

File.write!("elixir-companies.toml", toml)
