require 'nokogiri'
require 'date'
require 'time'


#ruby build_resourcelist.rb output_json

# ディレクトリとベースURLの設定
directory = ARGV.shift
base_url = "https://ddbj.nig.ac.jp/public/rdf/dev/resourcesync/#{directory}/"

# 現在の日時をISO8601形式で取得
current_time = Time.now.utc.iso8601

# NokogiriでXMLドキュメントを生成
builder = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
  xml.urlset('xmlns' => 'http://www.sitemaps.org/schemas/sitemap/0.9',
             'xmlns:rs' => 'http://www.openarchives.org/rs/terms/') {
    # ディレクトリ内のJSON-LDファイルを読み込む
    # rs:md at="2024-08-26T06:07:47Z" capability="resourcelist" completed="2024-08-26T06:07:47Z "
    xml['rs'].md(at: current_time, capability: 'resourcelist', completed: current_time)
    Dir.glob("#{directory}/*.jsonld") do |file|
      file_name = File.basename(file)
      file_url = "#{base_url}#{file_name}"

      xml.url {
        xml.loc file_url
        xml.lastmod File.mtime(file).iso8601
        #<rs:ln href="https://ddbj.nig.ac.jp/public/rdf/dev/resourcesync/PRJNA12143.json" rel="describes"/> 
        xml['rs'].ln(href: file_url, rel: "describes")
      }
    end
  }
end

# 生成されたXMLを文字列として取得
xml_content = builder.to_xml

# スタイルシート宣言を2行目に追加
stylesheet_declaration = '<!--<?xml-stylesheet href="resourcelist.xsl" type="text/xsl" ?>-->'
xml_content = xml_content.sub('<?xml version="1.0" encoding="UTF-8"?>', "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n#{stylesheet_declaration}")

# XMLファイルを保存
File.write("resourcelist-#{directory}.xml", xml_content)

puts "resourcelist.xmlが生成されました。"

