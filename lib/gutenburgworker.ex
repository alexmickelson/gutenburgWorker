defmodule GutenburgWorker do

  def get_books(trigram_url, starting_number, batch_size) do
    Enum.each(0..batch_size, fn(offset) ->
      do_get_books(trigram_url, starting_number + offset)
    end)
  end

  def do_get_books(trigram_url, number) do
    url =  "http://www.gutenberg.org/cache/epub/#{number}/pg#{number}.txt"
    body = get_body(url)
    titlePattern = ~r"Title: (?<title>[\S ]+)"
    # book = String.split(body, "***")
    %{ "title" => title } = Regex.named_captures(titlePattern, body)

    trigram_url = trigram_url <> "/api/trigram/createtrygrams"
    request_body = URI.encode_query(%{"title" =>title, "contents" => body })


    IO.puts "Sending request to trigram at #{trigram_url}"

    case HTTPoison.post(trigram_url, request_body)do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        IO.puts body
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        IO.puts "could not find #{trigram_url}"
      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.inspect(reason)
    end
  end

  def get_body(url) do
    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body, headers: headers}} ->
        case Enum.member?(headers, {"Content-Encoding", "gzip"}) do
          true -> :zlib.gunzip(body)
          false -> body
        end
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        IO.puts("Not found :(")
      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.inspect("Error")
        IO.inspect(reason)
    end
  end
end
