module ApplicationHelper
  COMMA  = ",".freeze
  ACTIVE = "active".freeze
  BLANK  = "".freeze

  def active_class(link_path)
    current_page?(link_path) ? ACTIVE : BLANK
  end

  def format_currency(money)
    "$#{number_with_precision money, delimiter: COMMA, precision: 0}"
  end
end
