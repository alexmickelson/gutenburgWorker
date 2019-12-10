defmodule GutenburgWorker do
  alias Poison, as: JSON

  def get_books(trigram_url, starting_number, batch_size) do
    Enum.each(0..batch_size, fn offset ->
      do_get_books(trigram_url, starting_number + offset)
    end)
  end

  def do_get_books(trygram_url, number) do
    url = "http://www.gutenberg.org/cache/epub/#{number}/pg#{number}.txt"
    trygram_url = trygram_url <> "/api/trygram/createtrygrams"

    {:ok, body} = get_body(url)
    titlePattern = ~r"Title: (?<title>[\S ]+)"
    %{"title" => title} = Regex.named_captures(titlePattern, body)

    book_parts = body
    |> String.codepoints()
    |> Stream.chunk_every(10_000)
    |> Stream.map(&Enum.join/1)

    res = Stream.each(book_parts, &spawn(fn ->
      send_request(&1, trygram_url, title)
    end))

    Enum.to_list(res)


    # Enum.each(book_parts, &fn &1 ->
    #   spawn(send_request(trygram_url, title, &1))
    # end)
  end
  # GutenburgWorker.do_get_books("http://144.17.24.80:30081", 2072)


  def send_request(body, url, title) do
    IO.puts("Sending request to trigram at #{url}, Title: #{title}")

    request_body = to_string(Poison.encode!(%{"title" => title, "text" => body}, []))

    case HTTPoison.post(url, request_body, [{"Content-Type", "application/json"}], recv_timeout: 20000) do
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        IO.puts "could not find #{url}"
      {:ok, %HTTPoison.Response{status_code: 500}} ->
        IO.puts "you broke the server"
      {:ok, %HTTPoison.Response{status_code: 200}} ->
        IO.puts "sucess"
      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.inspect(reason)
    end
  end

  def get_body(url) do
    case HTTPoison.get(url, recv_timeout: 2000) do
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
