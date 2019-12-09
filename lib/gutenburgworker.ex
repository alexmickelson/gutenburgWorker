defmodule GutenburgWorker do
  alias Poison, as: JSON

  def get_books(trigram_url, starting_number, batch_size) do
    Enum.each(0..batch_size, fn(offset) ->
      do_get_books(trigram_url, starting_number + offset)
    end)
  end

  def do_get_books(trigram_url, number) do
    url =  "http://www.gutenberg.org/cache/epub/#{number}/pg#{number}.txt"
    {:ok, body} = get_body(url)
    titlePattern = ~r"Title: (?<title>[\S ]+)"
    %{ "title" => title } = Regex.named_captures(titlePattern, body)

    trigram_url = trigram_url <> "/api/trygram/createtrygrams"
    request_body = URI.encode_query(%{"title" =>title, "contents" => body })
    request_body = to_string Poison.encode!(%{"title" =>title, "contents" => body }, [])

    IO.puts request_body

    IO.puts "Sending request to trigram at #{trigram_url}, Title: #{title}"

    case HTTPoison.post(trigram_url, request_body, [{"Content-Type", "application/json"}], [recv_timeout: 20000])do
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        IO.puts "could not find #{trigram_url}"
      {:ok, %HTTPoison.Response{status_code: 500}} ->
        IO.puts "you broke the server"
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        IO.puts body
      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.inspect(reason)
    end
  end

  def get_body(url) do
    case HTTPoison.get(url, [recv_timeout: 2000]) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body, headers: headers}} ->
        case Enum.member?(headers, {"Content-Encoding", "gzip"}) do
          true -> {:ok, :zlib.gunzip(body)}
          false -> {:ok, body}
        end
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        IO.puts("Not found :(")
        :not_found
      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.inspect("Error")
        IO.inspect(reason)
        :error
    end
  end
end
