# frozen_string_literal: true

module FundsHelper
  # Returns the status class for a fund based on remaining balance
  def fund_status_class(fund)
    return "danger" if fund.remaining_balance <= 0

    spent_percent = fund.amount > 0 ? (fund.total_spent / fund.amount * 100) : 0

    if spent_percent >= 90
      "danger"
    elsif spent_percent >= 75
      "warning"
    elsif spent_percent >= 50
      "caution"
    else
      "healthy"
    end
  end

  # Returns whether a fund should show an alert
  def fund_needs_alert?(fund)
    %w[danger warning].include?(fund_status_class(fund))
  end

  # Returns the alert message for a fund
  def fund_alert_message(fund)
    status = fund_status_class(fund)

    case status
    when "danger"
      if fund.remaining_balance <= 0
        "Fund depleted! No balance remaining."
      else
        "Critical: Only #{number_to_currency(fund.remaining_balance, unit: '₹', precision: 0)} left (#{100 - budget_used_percent(fund).round}% remaining)"
      end
    when "warning"
      "Warning: #{budget_used_percent(fund).round}% of budget used. #{number_to_currency(fund.remaining_balance, unit: '₹', precision: 0)} remaining."
    else
      nil
    end
  end

  # Returns the percentage of budget used
  def budget_used_percent(fund)
    return 0 unless fund.amount > 0
    (fund.total_spent / fund.amount * 100).clamp(0, 100)
  end

  # Returns the color class for the progress bar
  def fund_progress_color(fund)
    status = fund_status_class(fund)

    case status
    when "danger"
      "bg-red-500"
    when "warning"
      "bg-orange-500"
    when "caution"
      "bg-yellow-500"
    else
      "bg-green-500"
    end
  end

  # Returns funds that need attention
  def funds_needing_attention(funds)
    funds.select { |fund| fund_needs_alert?(fund) }
  end
end
