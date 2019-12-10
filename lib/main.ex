defmodule Commandline.CLI do
  alias GutenburgWorker
  def main(opts \\ []) do
    {options, _, _} = OptionParser.parse(
      opts,
      switches: [url: :string, start: :integer, batch: :integer]
    )

    # url = "http://www.gutenberg.org/cache/epub/2701/pg2701.txt"
    url = Keyword.get(options, :url, "http://144.17.24.80:30081")
    starting_number = Keyword.get(options, :start, 2701)
    batch_size = Keyword.get(options, :batch, 1)

    IO.puts "URL: "
    IO.puts url
    IO.puts "STARTING NUMBER: "
    IO.inspect starting_number
    IO.puts "BATCH SIZE: "
    IO.inspect batch_size

    GutenburgWorker.get_books(url, starting_number, batch_size)
  end
end
