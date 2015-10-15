module ApplicationHelper
  def active_class(link_path)
    current_page?(link_path) ? "active".freeze : "".freeze
  end

  def format_currency(money)
    "$#{number_with_precision money, delimiter: ',', precision: 0}"
  end
end
