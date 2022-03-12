defmodule Fakecast do
  import XmlBuilder
  alias __MODULE__.Book

  def stream_cover(book) do
    path = Path.join(book_dir(), book)
    cmd = ~w(ffmpeg -loglevel fatal -i) ++ [path] ++ ~w(-an -vcodec copy -f mjpeg pipe:1)
    Exile.stream!(cmd)
  end

  def get_books() do
    dir = book_dir()

    dir
    |> File.ls!()
    |> Task.async_stream(fn file ->
      get_book(dir, file)
    end)
    |> Stream.map(fn {:ok, res} -> res end)
    |> Enum.to_list()
  end

  def get_book(dir, path) do
    file_path = Path.join(dir, path)
    metadata = get_book_metadata(file_path)
    size = file_path |> File.stat!() |> Map.fetch!(:size)

    struct(
      Book,
      Map.merge(metadata, %{
        guid:
          :crypto.hash(:md5, metadata.title <> to_string(size))
          |> Base.url_encode64(padding: false),
        path: path,
        size: size
      })
    )
  end

  def get_book_metadata(path) do
    metadata =
      (~w(ffprobe -loglevel fatal -print_format json -show_format) ++ [path])
      |> Exile.stream!()
      |> Enum.to_list()
      |> Jason.decode!()
      |> Map.fetch!("format")

    %{
      duration: metadata["duration"] |> String.to_float() |> ceil,
      author: metadata["tags"]["artist"],
      title: metadata["tags"]["title"],
      description: metadata["tags"]["description"]
    }
  end

  def book_dir() do
    Path.join([:fakecast |> :code.priv_dir() |> to_string, "static", "books"])
  end

  def build(books, base_url, host_url) do
    document([
      element(
        :rss,
        %{
          version: "2.0",
          "xmlns:itunes": "http://www.itunes.com/dtds/podcast-1.0.dtd",
          "xmlns:content": "http://purl.org/rss/1.0/modules/content/"
        },
        [
          element(:channel, [
            element(:title, "My Audiobooks"),
            element(:description, "My Audiobooks"),
            element(:"itunes:image", %{href: Path.join([host_url, "images", "image.jpg"])}),
            element(:"itunes:block", "Yes")
            | for book <- books do
                element(:item, [
                  element(:title, book.title),
                  element(:description, book.description),
                  element(:guid, book.guid),
                  element(:"itunes:duration", book.duration),
                  element(:"itunes:image", %{
                    href:
                      Path.join([host_url, "cover", URI.encode(Path.basename(book.path, ".m4b"))])
                  }),
                  element(:enclosure, %{
                    type: "audio/x-m4b",
                    length: book.size,
                    url: Path.join([base_url, "books", URI.encode(book.path)])
                  })
                ])
              end
          ])
        ]
      )
    ])
    |> generate_iodata
  end
end
