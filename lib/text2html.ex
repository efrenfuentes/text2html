defmodule Text2Html do
  @moduledoc """
  Text2Html transform text into HTML.
  """

  @doc ~S"""
  Returns text transformed into HTML using simple formatting rules.

  Two or more consecutive newlines `\n\n` or `\r\n\r\n` are considered as a
  paragraph and text between them is wrapped in `<p>` tags.
  One newline `\n` or `\r\n` is considered as a linebreak and a `<br>` tag is inserted.

  ## Examples

      iex> Text2Html.text_to_html("Hello\n\nWorld") |> Phoenix.HTML.safe_to_string()
      "<p>Hello</p>\n<p>World</p>\n"

      iex> Text2Html.text_to_html("Hello\nWorld") |> Phoenix.HTML.safe_to_string()
      "<p>Hello<br>\nWorld</p>\n"

      iex> opts = [wrapper_tag: :div, attributes: [class: "p"]]
      ...> Text2Html.text_to_html("Hello\n\nWorld", opts) |> Phoenix.HTML.safe_to_string()
      "<div class=\"p\">Hello</div>\n<div class=\"p\">World</div>\n"

  ## Options

    * `:escape` - if `false` does not html escape input (default: `true`)
    * `:wrapper_tag` - tag to wrap each paragraph (default: `:p`)
    * `:attributes` - html attributes of the wrapper tag (default: `[]`)
    * `:insert_brs` - if `true` insert `<br>` for single line breaks (default: `true`)
    * `:links` - if `true` convert URLs to links (default: `false`)
    * `:links_opts` - options for the links conversion (default: `[]`)

  """
  @spec text_to_html(Phoenix.HTML.unsafe(), Keyword.t()) :: Phoenix.HTML.safe()
  def text_to_html(string, opts \\ []) do
    escape? = Keyword.get(opts, :escape, true)
    wrapper_tag = Keyword.get(opts, :wrapper_tag, :p)
    attributes = Keyword.get(opts, :attributes, [])
    insert_brs? = Keyword.get(opts, :insert_brs, true)
    links? = Keyword.get(opts, :links, false)
    links_opts = Keyword.get(opts, :links_opts, [])

    string
    |> maybe_html_escape(escape?)
    |> String.split(["\n\n", "\r\n\r\n"], trim: true)
    |> Enum.filter(&not_blank?/1)
    |> Enum.map(&wrap_paragraph(&1, wrapper_tag, attributes, insert_brs?, links?, links_opts))
    |> Phoenix.HTML.html_escape()
  end

  defp maybe_html_escape(string, true),
    do: string |> Phoenix.HTML.Engine.html_escape() |> IO.iodata_to_binary()

  defp maybe_html_escape(string, false),
    do: string

  defp not_blank?("\r\n" <> rest), do: not_blank?(rest)
  defp not_blank?("\n" <> rest), do: not_blank?(rest)
  defp not_blank?(" " <> rest), do: not_blank?(rest)
  defp not_blank?(""), do: false
  defp not_blank?(_), do: true

  defp wrap_paragraph(text, tag, attributes, insert_brs?, links?, links_opts) do
    text =
      text
      |> insert_brs(insert_brs?)
      |> convert_urls_to_links(links?, links_opts)

    [PhoenixHTMLHelpers.Tag.content_tag(tag, text, attributes), ?\n]
  end

  defp insert_brs(text, false) do
    text
    |> split_lines()
    |> Enum.intersperse(?\s)
    |> Phoenix.HTML.raw()
  end

  defp insert_brs(text, true) do
    text
    |> split_lines()
    |> Enum.map(&Phoenix.HTML.raw/1)
    |> Enum.intersperse([PhoenixHTMLHelpers.Tag.tag(:br), ?\n])
  end

  defp split_lines(text) do
    String.split(text, ["\n", "\r\n"], trim: true)
  end

  defp convert_urls_to_links(lines, false, _), do: lines

  defp convert_urls_to_links(lines, true, opts) do
    only_secure? = Keyword.get(opts, :only_secure, true)
    blank_target? = Keyword.get(opts, :blank_target, true)
    class = Keyword.get(opts, :class, nil)

    set_links([], lines, only_secure?, blank_target?, class)
  end

  defp url_regex(true) do
    ~r/https:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:%_\+.~#?&\/\/=]*)/
  end

  defp url_regex(false) do
    ~r/https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:%_\+.~#?&\/\/=]*)/
  end

  defp set_links(acc, [], _, _, _), do: acc

  defp set_links(acc, [line | rest], only_secure?, blank_target?, class) when is_list(line) do
    set_links(acc ++ [line], rest, only_secure?, blank_target?, class)
  end

  defp set_links(acc, [line | rest], only_secure?, blank_target?, class) do
    line = Phoenix.HTML.safe_to_string(line)

    links =
      Regex.scan(url_regex(only_secure?), line)
      |> Enum.map(&List.first(&1))
      |> Enum.uniq()

    line =
      links
      |> Enum.reduce(line, fn link, acc ->
        acc
        |> String.replace(
          link,
          "<a href=\"#{link}\"#{if blank_target?, do: " target=\"_blank\""}#{if !is_nil(class), do: " class=\"#{class}\""}>#{link}</a>"
        )
      end)

    line = Phoenix.HTML.raw(line)

    set_links(acc ++ [line], rest, only_secure?, blank_target?, class)
  end
end
