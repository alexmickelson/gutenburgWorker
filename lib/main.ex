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


  end

end
