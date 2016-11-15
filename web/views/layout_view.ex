defmodule Vutuv.LayoutView do
  use Vutuv.Web, :view
  import Vutuv.UserHelpers

  defp embed_css(conn) do
    filepath = File.cwd!<>"/priv/static"<>static_path(conn, "/css/app.css")
    case File.read(filepath) do
      {:ok, data} -> "<style>\n#{data}\n</style>"
      {:error, _} -> "<link rel=\"stylesheet\" href=\"#{static_path(conn, "/css/app.css")}\">"
    end
    |> raw
  end
end
