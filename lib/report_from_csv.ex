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
    |> Enum.reduce(initial_report, fn line, report -> process_data(line, report) end)
  end


  defp process_data([name, amount_of_hours, _day, month, year], report) do 
    report
    |> process_by_name(name, amount_of_hours)
    |> process_by_month(name, amount_of_hours, month)
    |> process_by_year(name, amount_of_hours, year)
  end


  defp process_by_name(report, _, ""), do: report
  defp process_by_name(report, name, amount_of_hours) do
    amount_of_hours = String.to_integer(amount_of_hours)
    all_hours = Map.update(report.all_hours, 
                            String.to_atom(name),
                            amount_of_hours,
                            fn current_value -> current_value + amount_of_hours
                            end)
    %{ report | all_hours: all_hours }
  end


  defp process_by_month(report, _, "", _), do: report
  defp process_by_month(report, name, amount_of_hours, month) do
    amount_of_hours = String.to_integer(amount_of_hours)
    
    hours_per_month = put_person_name(report.hours_per_month, name)    
    month_name = format_month_name(month)
    
    person_report = 
    Map.get(hours_per_month, String.to_atom(name))
    |> Map.update(String.to_atom(month_name),
                  amount_of_hours,
                    fn current_value -> current_value + amount_of_hours
                  end)

      
    hours_per_month = 
      hours_per_month
      |> Map.put(String.to_atom(name), person_report)
    
    %{ report | hours_per_month: hours_per_month}
  end


  defp process_by_year(report, _name, "", _year), do: report 
  defp process_by_year(report, name, amount_of_hours, year) do 
    amount_of_hours = String.to_integer(amount_of_hours)
    
    hours_per_year = put_person_name(report.hours_per_year, name)    
    
    person_report = 
    Map.get(hours_per_year, String.to_atom(name))
    |> Map.update(String.to_atom(year),
                  amount_of_hours,
                    fn current_value -> current_value + amount_of_hours
                  end)

      
    hours_per_year = 
      hours_per_year
      |> Map.put(String.to_atom(name), person_report)
    
    %{ report | hours_per_year: hours_per_year}
  end


  defp put_person_name(data, name) do
    if !Map.has_key?(data, String.to_atom(name)) do 
      Map.put(data, String.to_atom(name), %{})
    else
      data
    end
  end


  defp format_month_name(month) do
    case month do
      "1" -> "janeiro"
      "2" -> "fevereiro"
      "3" -> "marco"
      "4" -> "abril"
      "5" -> "maio"
      "6" -> "junho"
      "7" -> "julho"
      "8" -> "agosto"
      "9" -> "setembro"
      "10" -> "outubro"
      "11" -> "novembro"
      "12" -> "dezembro"
    end
  end

end
