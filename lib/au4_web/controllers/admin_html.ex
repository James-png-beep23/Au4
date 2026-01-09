defmodule Au4Web.AdminHTML do
  use Au4Web, :html

  embed_templates "admin_html/*"

  # Helper to format dates in the dashboard
  def format_date(nil), do: "N/A"
  def format_date(dt), do: Calendar.strftime(dt, "%y-%m-%d %H:%M")
end
