defmodule FakecastWeb.FeedController do
  use FakecastWeb, :controller

  def cover(conn, %{"book" => book}) do
    stream = Fakecast.stream_cover(book <> ".m4b")

    conn =
      conn
      |> put_resp_content_type("image/jpeg", nil)
      |> send_chunked(200)

    Enum.reduce_while(stream, conn, fn chunk, conn ->
      case chunk(conn, chunk) do
        {:ok, conn} -> {:cont, conn}
        {:error, :closed} -> {:halt, conn}
      end
    end)
  end

  def get(conn, _) do
    local_host = "#{get_local_ip()}.nip.io"
    port = FakecastWeb.Endpoint.config(:http) |> Keyword.fetch!(:port)

    local_url = %URI{host: local_host, port: port, scheme: "http"} |> URI.to_string()
    [host] = get_req_header(conn, "host")
    host_url = %URI{authority: host, scheme: Atom.to_string(conn.scheme)} |> URI.to_string()

    books = Fakecast.get_books()
    res = Fakecast.build(books, local_url, host_url)

    conn
    |> put_resp_content_type("application/rss+xml")
    |> resp(200, res)
  end

  defp get_local_ip() do
    :inet.getifaddrs()
    |> elem(1)
    |> Enum.find(&(elem(&1, 0) == 'en0'))
    |> elem(1)
    |> Enum.find(&match?({:addr, {_, _, _, _}}, &1))
    |> elem(1)
    |> Tuple.to_list()
    |> Enum.join(".")
  end
end
