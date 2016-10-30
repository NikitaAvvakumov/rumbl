defmodule InfoSys.Test.HTTPClient do
  @wolfram_xml File.read!("/Users/Nikita/coding/phoenix/rumbrella/apps/info_sys/test/fixtures/wolfram.xml")
  @empty_xml "<queryresult></queryresult>"

  def request(url) do
    url = to_string(url)
    test_query = URI.encode("to be?")
    cond do
      String.contains?(url, test_query) -> {:ok, {[], [], @wolfram_xml}}
      true -> {:ok, {[], [], @empty_xml}}
    end
  end
end
