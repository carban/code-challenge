require 'nokogiri'
require 'json'

# Pre-steps --------------------------------------------------
# Creating a hash to map images ids (keys) and base64 images (values)
#------------------------------------------------------------
def pre_process(doc)
  scripts = doc.css('script')
  ids = []
  imgs = []
  scripts.each do |s|
    id = s.text.match(/var ii=\['([^']+)'\];/)
    next if id == nil
    img = s.text.match(/var s='([^']+)';/)
    next if img == nil
    ids.push(id[1])
    imgs.push(img[1])
  end
  hash = ids.zip(imgs).to_h
  return hash
end

# Get Image --------------------------------------------------
# Function that looks for the base64 image into the hash
# In case not founded uses the 'data-src' value
#------------------------------------------------------------
def get_image(ele, hash)
  img_val = ''
  img_id = ele.at_css('img').attributes['id']
  if img_id != nil
    img_val = hash[img_id.text]
    img_val = img_val.gsub("\\x3d", "=") # fixing some base64 issues
  else
    img_val = ele.at_css('img').attributes['data-src'].value
  end
  return img_val
end

# Main process --------------------------------------------------
# Iterating over the elements of interest and building the results array
#------------------------------------------------------------
def process_elements(doc, hash)
  google_url = "https://www.google.com"
  elements = doc.css('div.iELo6 a')
  results_array = []
  
  elements.each do |ele|
    res = {}
    res['name'] = ele.css('div.pgNMRc').text
    res['extensions'] = [ele.css('div.cxzHyb').text] if ele.css('div.cxzHyb').text != ''
    res['link'] = google_url+ele.attributes['href']
    res['image'] = get_image(ele, hash)
    results_array << res
  end
  return results_array
end

# Main function --------------------------------------------------
def main
  # change it if you want to test other input E.g picasso-paintings
  input_name = "van-gogh-paintings" 
  file = "inputs/"+input_name+".html"
  html_content = File.read(file)
  doc = Nokogiri::HTML(html_content)
  
  hash = pre_process(doc)
  results_array = process_elements(doc, hash)

  File.open('results/'+input_name+'-result.json', 'w') do |file|
    file.write(JSON.pretty_generate({"artworks":results_array}))
  end
  puts input_name+" scraped!"
end

main()