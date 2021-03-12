defmodule ReportFromCsv do

  def call() do
  
    initial_report = %{ all_hours: %{}, 
                        hours_per_month: %{}, 
                        hours_per_year: %{}
                      }

    "./data/freela_data.csv" 
    |> File.stream!()
    |> Stream.map(&String.trim(&1, "\n"))
    |> Stream.map(&String.split(&1, ","))
    |> Enum.reduce(initial_report, fn line, report -> count_hours(line, report) end)
  end

  defp count_hours([name, amount_of_hours, day, mounth, year], report) do 
    report
    |> update_all_hours(name, amount_of_hours)
  end

  defp update_all_hours(report, _, ""), do: report
  defp update_all_hours(report, name, amount_of_hours) do
    amount_of_hours = String.to_integer(amount_of_hours)
    all_hours = Map.update(report.all_hours, 
                            String.to_atom(name),
                            amount_of_hours,
                            fn current_value -> 
                              current_value = current_value + amount_of_hours
                            end)
    %{ report | all_hours: all_hours }
  end



end
