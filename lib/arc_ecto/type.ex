defmodule Arc.Ecto.Type do
  def type, do: :string

  def cast(definition, args) do
    case definition.store(args) do
      {:ok, file} -> {:ok, %{file_name: file.file_name, updated_at: Ecto.DateTime.utc, identifier: file.identifier}}
      _ -> :error
    end
  end

  def load(_definition, value) do
    [file_name, gsec, identifier] = String.split(value, ";", parts: 3)

    updated_at = case gsec do
      gsec when is_binary(gsec) ->
        gsec
        |> String.to_integer()
        |> :calendar.gregorian_seconds_to_datetime()
        |> Ecto.DateTime.from_erl()
      _ ->
        nil
    end

    {:ok, %{file_name: file_name, updated_at: updated_at, identifier: identifier}}
  end

  def dump(_definition, %{file_name: file_name, updated_at: updated_at, identifier: identifier}) do
    gsec = :calendar.datetime_to_gregorian_seconds(Ecto.DateTime.to_erl(updated_at))
    {:ok, "#{file_name};#{gsec};#{identifier}"}
  end
end
