module ApplicationHelper

  def time_or_date(datetime)
    return '' if datetime.nil?
    format_string = datetime.today? ? '%I:%M %p' : datetime.strftime('%B %d, %Y')
    datetime.strftime format_string
  end
  def format_date(date, options = {})
    if options[:time]
      if options[:long]
        date ? date.strftime('%A %-m/%-d/%y %r') : ""
      else
        date ? date.strftime('%r %-m/%-d/%y') : ""
      end
    elsif options[:long]
      date ? date.strftime('%A %-m/%-d/%y') : ""
    else
      date ? date.strftime('%a %-m/%-d/%y') : ""
    end
  end

  def format_time(time, options = {})
    format_date time, time: true
  end

  def time_ago(date, options = {})
    if date.nil?
      nil
    else
      text = if date.to_date == Time.zone.now.to_date
               if options[:precise]
                 time_ago_in_words date
               else
                 t 'time.today'
               end
             else
               days_ago = (Time.zone.now.to_date - date.to_date).to_i
               if days_ago == 1
                 t 'time.yesterday'
               else
                 t 'time.days_ago', days: days_ago
               end
             end

      options[:parentheses] ? "(#{text})" : text
    end
  end

  def nav_item(name, selected = false)
    default_class = 'navItem'
    "<a class='#{default_class}#{selected ? ' selected' : ''}'>#{name}</a>".html_safe
  end

  def nav_link(controller, options = {})
    default_class = 'navItem'
    text = options[:text] || t(".#{controller}")
    action = options[:action] || 'index'
    path = options[:path] || send("#{controller}_path")
    if params[:controller] == controller
        if params[:action] == action
          nav_item(text, true)
        else
          link_to(text, path, class: default_class)
        end
    else
      link_to(text, path, class: default_class)
    end
  end
end
