# -*- encoding :utf-8 -*-

require 'net/http'
require 'open-uri' # open関数でurlを読み込む為に必要
require 'json'


require 'base64'
require 'uri'
require 'hmac'
require 'hmac-sha1'

class Building < ActiveRecord::Base
  acts_as_gmappable
  
  # belongs_to :biru_marker
  has_many :trusts
  has_many :owners, :through=>:trusts
  has_many :building_routes
  belongs_to :shop
  belongs_to :build_type
  has_many :rooms
  belongs_to :biru_user
  has_many :documents
  has_many :building_near_station
  belongs_to :occur_source


  # デフォルトスコープを定義
  #default_scope { where(delete_flg: false) }.includes(:shop).includes(:build_type).includes(:trusts).includes(:trusts => :owner)
  # ↑ 最初からスコープでincludesを指定しようと思ったが、管理では使うが募集では不要な結合なので、使う検索の時に別途結合するようにする。
  default_scope { where(delete_flg: false) }
  scope :oneself , -> { where(:attack_code => nil )}

  def gmaps4rails_address
   "#{self.address}"
  end

  def gmaps4rails_infowindow
    "<h3>#{name}</h3>"
  end

  def gmaps4rails_sidebar
    "<span class=""foo"">#{name}</span>"
  end
  
  # クラスメソッド定義
  class << self
	  # 指定されたコードの物件情報を返す。（存在しないときは、OBICから取得した情報で新規作成して返す）
	  def force_get_by_code(code)
	  	  
	  	  code_int = code.to_i
	  	  building = Building.unscoped.find_by_code(code_int)
	  	  
	  	  if building
	  	  	  
	  	  	  if building.delete_flg
	  	  	  	  building.delete_flg = false
	  	  	  	  building.save!
	  	  	  end
	  	  	  
	  	  else
	  	  	  # 存在しないときはOBICのViewからbuildingを検索し作成する(それでも存在しなければbuildingはnilが返る)
	  	  	  
						sql = "SELECT * FROM OBIC_VW_BukkenJouhou WHERE BukkenCD = '" + code + "'"
						p '◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆'
						p sql
						
						ActiveRecord::Base.connection.select_all(sql).each do |rec|
								building = Building.new
								building.code = rec['BukkenCD'].to_i.to_s
								building.name = rec['BukkenName']
								building.address = ""
								if rec['Juusho1']
									building.address = building.address + rec['Juusho1']
							  end
							  
								if rec['Juusho3']
									building.address = building.address + rec['Juusho3']
								end
								
								
								begin
									building.save!
								rescue => e
									building.gmaps = true
									building.save!
								end
						end
	  	  end
	  	  
	  	  return building
	  end
  end
  
  
  # 物件が重点地域かどうかを文字で表示
  def selective_disp
    case self.selective_type
    when 0
      '-'
    when 1
      '重点'
    when 2
      '準重点'
    else
      '不明'
    end
  end
  
  # 指定した住所から郵便番号を取得します。
  def parse_postcode()
    
    # 郵便番号が未設定の場合は郵便番号を取得
    unless self.postcode
      
      url = "https://maps.googleapis.com/maps/api/geocode/json?latlng=#{self.latitude.to_s},#{self.longitude.to_s}&sensor=false&client=gme-chuobuildingkanri"
      a = signURL("ms4rVf_yzC5Ejdn4qJqyHoLMVRY=", url).chomp.to_s
      uri = URI.parse(a)
  
      json = open(uri).read
    
      result = JSON.parse(json)
      if result["status"] == "OK"
      
        result["results"][0]["address_components"].each do |arr|
          if arr["types"][0] == "postal_code"
          
            # 物件情報に対し、逆geocodeして郵便番号を設定
            self.postcode = arr["long_name"]
            break
          end
        end
      
      else
        # 取得できなければエラー
        return 'NG'
      end
      
    end
    
    
    if self.postcode

      # 設定した郵便番号が重点実施郵便番号であれば、重点実施フラグを設定する（そうでなければそのフラグを外す）
      selectively = SelectivelyPostcode.find_by_postcode( self.postcode )
      if selectively
        self.selective_type = selectively.selective_type
      else
        self.selective_type = 0
      end
    
      return self.postcode
    else
      return 'NG'
    end

  end
  
  
  # 2014/08/17 takashi add
  def urlSafeBase64Decode(base64String)
    return Base64.decode64(base64String.tr('-_','+/'))
  end

  # 2014/08/17 takashi add
  def urlSafeBase64Encode(raw)
    return Base64.encode64(raw).tr('+/','-_')
  end

  # 2014/08/17 takashi add
  def signURL(key, url)
    parsedURL = URI.parse(url)
    urlToSign = parsedURL.path + '?' + parsedURL.query

    # Decode the private key
    rawKey = urlSafeBase64Decode(key)

    # create a signature using the private key and the URL
    sha1 = HMAC::SHA1.new(rawKey)
    sha1 << urlToSign
    rawSignature = sha1.digest()

    # encode the signature into base64 for url use form.
    signature =  urlSafeBase64Encode(rawSignature)

    # prepend the server and append the signature.
    signedUrl = parsedURL.scheme+"://"+ parsedURL.host + urlToSign + "&signature=#{signature}"
    return signedUrl
  end
  

end
