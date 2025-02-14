defmodule Text2HtmlTest do
  use ExUnit.Case

  doctest Text2Html

  import Text2Html

  test "wraps paragraphs" do
    formatted =
      format("""
      Hello,

      Please come see me.

      Regards,
      The Boss.
      """)

    assert formatted == """
           <p>Hello,</p>
           <p>Please come see me.</p>
           <p>Regards,<br>
           The Boss.</p>
           """
  end

  test "wraps paragraphs with carriage returns" do
    formatted = format("Hello,\r\n\r\nPlease come see me.\r\n\r\nRegards,\r\nThe Boss.")

    assert formatted == """
           <p>Hello,</p>
           <p>Please come see me.</p>
           <p>Regards,<br>
           The Boss.</p>
           """
  end

  test "escapes html" do
    formatted =
      format("""
      <script></script>
      """)

    assert formatted == """
           <p>&lt;script&gt;&lt;/script&gt;</p>
           """
  end

  test "skips escaping html" do
    formatted =
      format(
        """
        <script></script>
        """,
        escape: false
      )

    assert formatted == """
           <p><script></script></p>
           """
  end

  test "adds brs" do
    formatted =
      format("""
      Hello,
      This is dog,
      How can I help you?


      """)

    assert formatted == """
           <p>Hello,<br>
           This is dog,<br>
           How can I help you?</p>
           """
  end

  test "adds brs with carriage return" do
    formatted = format("Hello,\r\nThis is dog,\r\nHow can I help you?\r\n\r\n\r\n")

    assert formatted == """
           <p>Hello,<br>
           This is dog,<br>
           How can I help you?</p>
           """
  end

  test "doesn't add brs" do
    formatted =
      format(
        """
        Hello,
        This is dog,
        How can I help you?


        """,
        insert_brs: false
      )

    assert formatted == """
           <p>Hello, This is dog, How can I help you?</p>
           """
  end

  test "set_links" do
    formatted =
      format(
        """
        You should try http://www.google.com
        It's not secure.

        You should try it.
        """,
        links: true,
        links_opts: [only_secure: false, blank_target: false]
      )

    assert formatted == """
           <p>You should try <a href="http://www.google.com">http://www.google.com</a><br>\nIt&#39;s not secure.</p>\n<p>You should try it.</p>
           """
  end

  test "set_links only secure links with blank_target and class" do
    formatted =
      format(
        """
        You should try http://www.google.com
        It's not secure.

        But https://www.google.com is secure.

        You should try it.
        """,
        links: true,
        links_opts: [only_secure: true, blank_target: true, class: "text-blue-500"]
      )

    assert formatted == """
           <p>You should try http://www.google.com<br>\nIt&#39;s not secure.</p>\n<p>But <a href="https://www.google.com" target=\"_blank\" class=\"text-blue-500\">https://www.google.com</a> is secure.</p>\n<p>You should try it.</p>
           """
  end

  defp format(text, opts \\ []) do
    text |> text_to_html(opts) |> Phoenix.HTML.safe_to_string()
  end
end
