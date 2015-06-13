defmodule UDPFlux.DataPoint do
  defstruct name: "", tags: [], fields: []

  def dump(point) do
    tags = point.tags |> Enum.map_join(",", &encode_tag/1)
    fields = point.fields |> Enum.map_join(",", &encode_field/1)
    # Construct string: "name,tag=tagvalue,tag2=tagvalue2 field=fieldval1,field2=fieldval2"
    # Timestamp is automatically added by influxdb
    point.name <> "," <> tags <> " " <> fields
  end

  defp encode_tag({key, value}) do
    to_string(key) <> "=" <> fuck_up_string_according_to_spec(to_string(value))
  end

  defp encode_field({key, value}) when is_binary(value) do
    to_string(key) <> "=\"" <> fuck_up_string_according_to_spec(to_string(value)) <> "\""
  end

  defp encode_field({key, value}) do
    to_string(key) <> "=" <> to_string(value)
  end

  defp fuck_up_string_according_to_spec(string) do
    string |>
      String.replace(" ", "\\ ") |>
      String.replace(",", "\\,") |>
      String.replace("=", "\\=")
  end
end
