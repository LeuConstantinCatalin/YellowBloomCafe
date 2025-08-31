module ApplicationHelper
  def image_for_category(category)
    case category.to_s
    when 'Cafele'
      'Cafea.png'
    when 'Prajituri'
      'Prajitura.png'
    when 'Bauturi racoritoare'
      'Racoritoare.png'
    when 'Smoothie-uri'
      'Smoothie.png'
    else
      'YF-PNG-resize5.png'
    end
  end
end
