# encoding : utf-8
class PdfReport < Prawn::Document
  def to_pdf(model, mode_scope)
    
    columns = model.attribute_names
    
    data = [columns]

    mode_scope.each{ |modelobj| 
      data << (columns.map{ |c| modelobj[c].to_s }).to_a
    }
    
    table data, :header => true, :cell_style => { :padding => 5 } do
        i = 0
        for col in columns
          align = case model.columns_hash[col].type
            when "integer" then
              'right'
            when "string", "text" then
              'left'
            else   
              'center'
          end
          style(columns(i)){ |c| c.align = align.to_sym }
          i += 1
        end
    end
    
    # Paginate
    font_size 10
    number_pages Time.now.strftime('%d/%m/%Y - %H:%M') + ' - <page>/<total>', :at => [0, -5], :align => :center
    repeat(:all) do
      bounding_box([0,0], :width => 540, :height => 2) do
        stroke_horizontal_rule
      end
    end
    
    render
  end
end