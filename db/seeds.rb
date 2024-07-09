require 'net/http'
require 'json'

def fetch_place_details(place_name, api_key)
  base_url = "https://maps.googleapis.com/maps/api/place/findplacefromtext/json"
  query = "?input=#{URI.encode_www_form_component(place_name)}&inputtype=textquery&fields=photos,formatted_address,geometry&key=#{api_key}"
  url = base_url + query

  uri = URI(url)
  response = Net::HTTP.get(uri)
  response = JSON.parse(response)

  return if response["candidates"].empty?

  place_id = response["candidates"].first["place_id"]

  details_url = "https://maps.googleapis.com/maps/api/place/details/json"
  details_query = "?place_id=#{place_id}&fields=name,formatted_address,photos,geometry&key=#{api_key}"
  details_uri = URI(details_url + details_query)
  details_response = Net::HTTP.get(details_uri)
  details_response = JSON.parse(details_response)

  details_response["result"]
end

api_key = ENV['GOOGLE_PLACES_API_KEY']

shops = [
  { name: "中華蕎麦福はら", address: "大阪府東大阪市俊徳町１丁目３−２４", introduction: "当店の味の要といえる“煮干し”。小豆島いりこを用い、当店用に調整していただいた特注品を仕入れています。", genre: "淡麗", image_url: "https://lh5.googleusercontent.com/p/AF1QipPcZy4_Jc6l9oN9cYCFCt4Edm_HrDK2M5V7kqi4=w300-h450-p-k-no" },
  { name: "NAKAGAWA わず", address: "大阪府大阪市東淀川区菅原６丁目２４−１２", introduction: "JR淡路駅近くにあり、毎日異なる煮干ラーメンを提供しているお店。今日の限定を知りたい場合はTwitterアカウントをチェック", genre: "濃厚", image_url: "https://lh5.googleusercontent.com/p/AF1QipN6VBHqPiF0nC5-wFNrbgtobA0nJiSeTHE8kZvt=s508-p-k-no" },
  { name: "らーめんセンタートミオ", address: "大阪府大阪市生野区生野西２丁目１−２７", introduction: "2020/1/18開業 煮干し中華そば・煮干しざる（つけ麺）・濃厚煮干し中華そば.シウマイも名物です。", genre: "濃厚", image_url: "https://i.imgur.com/zNcCBxv.jpg" },
  { name: "魚々麺 園", address: "大阪府東大阪市足代南１丁目３−１２", introduction: "落ち着いた内装のラーメン店。ズワイガニの味噌など、さまざまな魚介を使ったラーメンが人気。", genre: "濃厚", image_url: "https://lh5.googleusercontent.com/p/AF1QipNJFEFa6pMnaHR8D-ZoP0QWnpF8_VUW6u0pRZQi=s451-p-k-no" },
  { name: "煮干らあめん じんべえ", address: "滋賀県草津市笠山５丁目１−６８", introduction: "当店は魚と小麦にこだわっております。産地まで足を運び厳選した、ひうち媛いりこ、焼片口いわし、うるめなどを中心に数種類の国産煮干を惜しみなく使ったスープ。", genre: "淡麗", image_url: "https://i.imgur.com/WkwkyeB.jpg" },
  { name: "麺や而今 大東本店", address: "大阪府大東市灰塚６丁目７−９", introduction: "鶏ガラしょうゆのラーメンが人気。だが、木金のみの限定で提供される煮干ラーメンは超絶美味。", genre: "淡麗", image_url: "https://i.imgur.com/p8TN1KN.jpg" },
  { name: "麺屋 いちびり NEXT", address: "大阪府藤井寺市藤ヶ丘３丁目１２−１１", introduction: "奈良県橿原市に本店を構える【麺屋 いちびり】の3号店です。大阪では珍しい煮干し鶏白湯ラーメンを提供しているお店。", genre: "淡麗", image_url: "https://lh5.googleusercontent.com/p/AF1QipMA0mjJHBCSjoZZB8xOj-dDvFy_50oI5E8JICNK=s406-p-k-no" },
  { name: "中華そば かむら", address: "滋賀県大津市唐崎１丁目９−３", introduction: "地鶏と蛤出汁に国産小麦『はるゆたか』使用。化学調味料不使用の中華そば、つけそば、シュウマイが名物", genre: "淡麗", image_url: "https://i.imgur.com/mgtg4KK.jpg" },
  { name: "煮干し中華そば 加藤屋本店", address: "京都府京都市山科区東野百拍子町２５−２", introduction: "2021年3月22日新店舗オープン。限定の幻の中華そばや煮干しを効かせた魚介系スープのラーメンが人気です", genre: "淡麗", image_url: "https://lh5.googleusercontent.com/p/AF1QipO33-3LnifR16G52I2saYaX_YCboQxmurI-osgL=s451-p-k-no" },
  { name: "加藤屋にぼ次朗 南草津店", address: "滋賀県草津市野路１丁目１２−２３", introduction: "にぼ次郎という名前で知られる二郎系×煮干しラーメンのお店。煮干しラーメンは濃厚でありながらも醤油が強く後味がさっぱりしているのが特徴。", genre: "濃厚", image_url: "https://lh5.googleusercontent.com/p/AF1QipMDlEGkH2Hy-YvhLUST9ddpZYDFacI2NDuc_xRi=s387-p-k-no" },
  { name: "セアブラノ神 壬生本店", address: "京都府京都市中京区壬生相合町２５−４ デイスターアベニュー 1Ｆ", introduction: "新潟のご当地ラーメンである燕三条系ラーメンを、当店流にアレンジ。背脂がスープ面を覆うビジュアルからこってりそうに見えますが、食べるとあっさり。", genre: "濃厚", image_url: "http://www.seaburanokami.jp/_p/acre/16788/images/pc/681a083f.png" },
  { name: "極汁美麺 umami", address: "大阪府東大阪市菱屋西３丁目１−１", introduction: "レギュラーメニューの鶏醤油ラーメンに加えて定期的に変更される限定ラーメンを提供。ドロドロの冷やし煮干つけ麺は濃厚だが煮干し好きなら絶品", genre: "つけ麺", image_url: "https://i.imgur.com/lBfOYgQ.jpg" }
]

shops.each do |shop|
  puts "Processing #{shop[:name]}"
  place_details = fetch_place_details(shop[:name], api_key)

  if place_details
    address = place_details["formatted_address"]
    latitude = place_details["geometry"]["location"]["lat"]
    longitude = place_details["geometry"]["location"]["lng"]

    # 詳細ページで使用する画像URLを取得
    photo_reference = place_details["photos"]&.first&.fetch("photo_reference", nil)
    photo_url = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=#{photo_reference}&key=#{api_key}" if photo_reference

    ramen_shop = RamenShop.create!(
      name: shop[:name],
      address: address,
      introduction: shop[:introduction],
      genre: shop[:genre],
      latitude: latitude,
      longitude: longitude,
      image_url: shop[:image_url],
      detail_image_url: photo_url # 詳細ページ用の画像URLを保存
    )
    puts "#{shop[:name]} created with detail_image_url: #{ramen_shop.detail_image_url}"
  else
    # Google Places APIで情報が取得できなかった場合、手動で入力された情報を使用
    ramen_shop = RamenShop.create!(
      name: shop[:name],
      address: shop[:address],
      introduction: shop[:introduction],
      genre: shop[:genre],
      latitude: nil,
      longitude: nil,
      image_url: shop[:image_url], # 手動で設定した画像URLを使用
      detail_image_url: nil
    )
    puts "#{shop[:name]} created with manual image_url: #{ramen_shop.image_url}"
  end
end

puts "Seed data created successfully."
