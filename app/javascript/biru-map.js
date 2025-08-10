
// グローバル変数 ストリートビューの縦分割を指定する。2014/10/10
var street_vew_vertical = false;

// forEachを未実装のブラウザで使えるようにする設定
// Production steps of ECMA-262, Edition 5, 15.4.4.18
// Reference: http://es5.github.com/#x15.4.4.18
if ( !Array.prototype.forEach ) {
  Array.prototype.forEach = function( callback, thisArg ) {

    var T, k;

    if ( this == null ) {
      throw new TypeError( " this is null or not defined" );
    }

    // 1. Let O be the result of calling ToObject passing the |this| value as the argument.
    var O = Object(this);

    // 2. Let lenValue be the result of calling the Get internal method of O with the argument "length".
    // 3. Let len be ToUint32(lenValue).
    var len = O.length >>> 0; // Hack to convert O.length to a UInt32

    // 4. If IsCallable(callback) is false, throw a TypeError exception.
    // See: http://es5.github.com/#x9.11
    if ( {}.toString.call(callback) != "[object Function]" ) {
      throw new TypeError( callback + " is not a function" );
    }

    // 5. If thisArg was supplied, let T be thisArg; else let T be undefined.
    if ( thisArg ) {
      T = thisArg;
    }

    // 6. Let k be 0
    k = 0;

    // 7. Repeat, while k < len
    while( k < len ) {

      var kValue;

      // a. Let Pk be ToString(k).
      //   This is implicit for LHS operands of the in operator
      // b. Let kPresent be the result of calling the HasProperty internal method of O with argument Pk.
      //   This step can be combined with c
      // c. If kPresent is true, then

      if ( k in O ) {

        // i. Let kValue be the result of calling the Get internal method of O with argument Pk.
        kValue = O[ k ];

        // ii. Call the Call internal method of callback with T as the this value and
        // argument list containing kValue, k, and O.
        callback.call( T, kValue, k, O );
      }
      // d. Increase k by 1.
      k++;
    }
    // 8. return undefined
  };
}


/* 
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

// グローバル変数定義
var infoWnd;  // 吹き出しウィンドウ
var panoramaOptions; // ストリートビュー定義
var panorama;
var mapCanvas;

// フルスクリーンを表示するボタン定義
function FullScreenControl(map) {
    var controlDiv = document.createElement('div');
    controlDiv.index = 1;
    controlDiv.style.padding = '5px';

    // Set CSS for the control border.
    var controlUI = document.createElement('div');
    controlUI.style.backgroundColor = 'white';
    controlUI.style.borderStyle = 'solid';
    controlUI.style.borderWidth = '1px';
    controlUI.style.borderColor = '#717b87';
    controlUI.style.cursor = 'pointer';
    controlUI.style.textAlign = 'center';
    controlUI.style.boxShadow = '0px 2px 4px rgba(0,0,0,0.4)';
    controlDiv.appendChild(controlUI);

    // Set CSS for the control interior.
    var controlText = document.createElement('div');
    controlText.style.fontFamily = 'Arial,sans-serif';
    controlText.style.fontSize = '13px';
    controlText.style.paddingTop = '1px';
    controlText.style.paddingBottom = '1px';
    controlText.style.paddingLeft = '6px';
    controlText.style.paddingRight = '6px';
    controlText.innerHTML = '<strong>Full Screen</strong>';
    controlUI.appendChild(controlText);

    var fullScreen = false;
    var mapDiv = map.getDiv();
    var divStyle = mapDiv.style;
    if (mapDiv.runtimeStyle)
            divStyle = mapDiv.runtimeStyle;
    var originalPos = divStyle.position;
    var originalWidth = divStyle.width;
    var originalHeight = divStyle.height;
    var originalTop = divStyle.top;
    var originalLeft = divStyle.left;
    var originalZIndex = divStyle.zIndex;

    var bodyStyle = document.body.style;
    if (document.body.runtimeStyle)
            bodyStyle = document.body.runtimeStyle;
    var originalOverflow = bodyStyle.overflow;

    // Setup the click event listener
    google.maps.event.addDomListener(controlUI, 'click', function() {
            var obj = document.getElementById("simple-menu");

            var center = map.getCenter();
            if (!fullScreen) {

                    obj.click();

                    divStyle.position = "fixed";
                    divStyle.width = "100%";
                    divStyle.height = "100%";
                    divStyle.top = "0";
                    divStyle.left = "0";
                    divStyle.zIndex = "100";
                    bodyStyle.overflow = "hidden";
                    controlText.innerHTML = '<strong>Exit full screen</strong>';
            }
            else {

                    obj.click();

                    if (originalPos == "")
                            divStyle.position = "relative";
                    else
                            divStyle.position = originalPos;
                    divStyle.width = originalWidth;
                    divStyle.height = originalHeight;
                    divStyle.top = originalTop;
                    divStyle.left = originalLeft;
                    divStyle.zIndex = originalZIndex;
                    bodyStyle.overflow = originalOverflow;
                    controlText.innerHTML = '<strong>Full Screen</strong>';
            }
            fullScreen = !fullScreen;
            google.maps.event.trigger(map, 'resize');
            map.setCenter(center);
    });

    return controlDiv;
}


function MenuControll(map) {
    
    var controlDiv = document.createElement('div');
    controlDiv.index = 1;
    controlDiv.style.padding = '5px';

    // Set CSS for the control border.
    var controlUI = document.createElement('div');
    controlUI.style.backgroundColor = 'white';
    controlUI.style.borderStyle = 'solid';
    controlUI.style.borderWidth = '1px';
    controlUI.style.borderColor = '#717b87';
    controlUI.style.cursor = 'pointer';
    controlUI.style.textAlign = 'center';
    controlUI.style.boxShadow = '0px 2px 4px rgba(0,0,0,0.4)';
    controlDiv.appendChild(controlUI);

    // Set CSS for the control interior.
    var controlText = document.createElement('div');
    controlText.style.fontFamily = 'Arial,sans-serif';
    controlText.style.fontSize = '13px';
    controlText.style.paddingTop = '1px';
    controlText.style.paddingBottom = '1px';
    controlText.style.paddingLeft = '6px';
    controlText.style.paddingRight = '6px';
    controlText.innerHTML = '<strong>メニュー&nbsp;&nbsp;表示</strong>';
    controlUI.appendChild(controlText);

    var fullScreen = false;
    var mapDiv = map.getDiv();
    var divStyle = mapDiv.style;

    // Setup the click event listener
    google.maps.event.addDomListener(controlUI, 'click', function() {
      var obj = document.getElementById("simple-menu");

			// 2014/04/16 safari対応でクリックはクリックイベント経由で行う
			var click_ev = document.createEvent("MouseEvent");
			click_ev.initEvent("click", true, true);
			

      if (!fullScreen) {
      	// 2014/04/16 safari対応でクリックはクリックイベント経由で行う
        //obj.click();
        obj.dispatchEvent(click_ev);
        
        controlText.innerHTML = '<strong>メニュー非表示</strong>';
        //divStyle.marginLeft = "500px";
        //divStyle.width = "80%";

      }
      else {
      	// 2014/04/16 safari対応でクリックはクリックイベント経由で行う
        //obj.click();
        obj.dispatchEvent(click_ev);
        
        controlText.innerHTML = '<strong>メニュー&nbsp;&nbsp;表示</strong>';
        //divStyle.marginLeft = "0px";
        //divStyle.width = "100%";
      }
      fullScreen = !fullScreen;
    });

    return controlDiv;
}

function BarControll(map, user_id) {
    
    var controlDiv = document.createElement('div');
    controlDiv.index = 1;
    controlDiv.style.padding = '5px';
    controlDiv.style.marginRight = '10px';
    controlDiv.style.marginTop = '-50px';


    // Set CSS for the control border.
    var controlUI = document.createElement('div');
    controlUI.style.backgroundColor = 'white';
    controlUI.style.borderStyle = 'solid';
    controlUI.style.borderWidth = '1px';
    controlUI.style.borderColor = '#717b87';
    controlUI.style.cursor = 'pointer';
    controlUI.style.textAlign = 'center';
    controlUI.style.boxShadow = '0px 2px 4px rgba(0,0,0,0.4)';
    controlUI.style.height = '350px';
    controlUI.style.width = '200px';
    controlUI.style.top = '10px';
    controlDiv.appendChild(controlUI);

    var divRadio = document.createElement('div');
    divRadio.style.position = 'absolute';
    divRadio.style.top = '25px';
    divRadio.style.left = '30px';
    divRadio.style.left = '25px';
    var strRadio = ""

    strRadio = strRadio + '<form accept-charset="UTF-8" action="/biruweb/managements/change_biru_icon" data-remote="true" format="js" id="biru_icon_id" method="post" name="biru_icon">'
    strRadio = strRadio + '  <div style="margin:0;padding:0;display:inline">'
    strRadio = strRadio + '    <input name="utf8" type="hidden" value="&#x2713;" />'
    strRadio = strRadio + '    <input name="authenticity_token" type="hidden" value="JEzEMF2O+DTDMazjGjDPHR3BNof0wPWpYp3uIceXX7M=" /></div>'
    strRadio = strRadio + '    <input name="user_id" type="hidden" value="' + user_id + '" />'
    strRadio = strRadio + '  </div>'
    strRadio = strRadio + '  <select id="disp_type" name="disp_type" onChange="change_icon();" style="width:150px;">'
    strRadio = strRadio + '    <option value="biru_kind">建物種別</option>'
    strRadio = strRadio + '    <option value="siten">支店</option>'
    strRadio = strRadio + '    <option value="area">エリア</option>'
    strRadio = strRadio + '    <option value="shop">営業所</option>'
    strRadio = strRadio + '    <option value="manage_type">管理方式</option>'
    strRadio = strRadio + '    <option value="aki">空室数</option>'
    strRadio = strRadio + '    <option value="age">築年数</option>'
    strRadio = strRadio + '    <option value="num">戸数</option>'
    strRadio = strRadio + '    <option value="jita">自他</option>'
    strRadio = strRadio + '    <option value="atk">アタックランク</option>'
    strRadio = strRadio + '  </select>'
    strRadio = strRadio + '  <input name="s_commit" style="display:none;" type="submit" value="" />'
    strRadio = strRadio + '</form>'

    divRadio.innerHTML = strRadio
    controlDiv.appendChild(divRadio);

    var divA = document.createElement('div');
    divA.style.position = 'absolute';
    divA.style.top = '75px';
    divA.style.left = '10px';
    divA.id = "biru_icon"

    var strTable = ""
    strTable = strTable + '<table style="margin-left:30px;">'
    strTable = strTable + '   <tbody>'
    strTable = strTable + '     <tr >'
    strTable = strTable + '       <td style="text-align:left;height:20px;width:25px;"><img alt="Marker_blue" src="/biruweb/assets/marker_blue.png" /></td>'
    strTable = strTable + '       <td style="text-align:left;height:5px;font-size:medium;">アパート</td>'
    strTable = strTable + '     </tr>'
    strTable = strTable + '     <tr>'
    strTable = strTable + '       <td><img alt="Marker_yellow" src="/biruweb/assets/marker_yellow.png" /></td>'
    strTable = strTable + '       <td style="font-size:medium;">マンション</td>'
    strTable = strTable + '     </tr>'
    strTable = strTable + '     <tr>'
    strTable = strTable + '       <td><img alt="Marker_purple" src="/biruweb/assets/marker_purple.png" /></td>'
    strTable = strTable + '       <td style="font-size:medium;">分譲M</td>'
    strTable = strTable + '     </tr>'
    strTable = strTable + '     <tr>'
    strTable = strTable + '       <td><img alt="Marker_red" src="/biruweb/assets/marker_red.png" /></td>'
    strTable = strTable + '       <td style="font-size:medium;">戸建て</td>'
    strTable = strTable + '     </tr>'
    strTable = strTable + '     <tr>'
    strTable = strTable + '       <td><img alt="Marker_orange" src="/biruweb/assets/marker_orange.png" /></td>'
    strTable = strTable + '       <td style="font-size:medium;">テラス</td>'
    strTable = strTable + '     </tr>'
    strTable = strTable + '     <tr>'
    strTable = strTable + '       <td><img alt="Marker_green" src="/biruweb/assets/marker_green.png" /></td>'
    strTable = strTable + '       <td style="font-size:medium;">メゾネット</td>'
    strTable = strTable + '     </tr>'
    strTable = strTable + '     <tr>'
    strTable = strTable + '       <td><img alt="Marker_gray" src="/biruweb/assets/marker_gray.png" /></td>'
    strTable = strTable + '       <td style="font-size:medium;">店舗等</td>'
    strTable = strTable + '     </tr>'
    strTable = strTable + '     <tr>'
    strTable = strTable + '       <td><img alt="Marker_gray" src="/biruweb/assets/marker_gray.png" /></td>'
    strTable = strTable + '       <td style="font-size:medium;">事務所等</td>'
    strTable = strTable + '     </tr>'
    strTable = strTable + '     <tr>'
    strTable = strTable + '       <td><img alt="Marker_white" src="/biruweb/assets/marker_white.png" /></td>'
    strTable = strTable + '       <td style="font-size:medium;">その他</td>'
    strTable = strTable + '     </tr>'
    strTable = strTable + '   </tbody>'
    strTable = strTable + ' </table>'
    
    divA.innerHTML = strTable
    controlDiv.appendChild(divA);

    // Set CSS for the control interior.
//   var controlText = document.createElement('div');
//   controlText.style.fontFamily = 'Arial,sans-serif';
//   controlText.style.fontSize = '13px';
//   controlText.style.paddingTop = '1px';
//   controlText.style.paddingBottom = '1px';
//   controlText.style.paddingLeft = '6px';
//   controlText.style.paddingRight = '6px';
//   controlText.innerHTML = '<strong>メニュー&nbsp;&nbsp;表示</strong>';
//   controlUI.appendChild(controlText);

    return controlDiv;
}


function DispControll(map, market_flg) {

    var controlDiv = document.createElement('div');
    controlDiv.index = 1;
    controlDiv.style.padding = '5px';
    controlDiv.style.marginRight = '10px';

    // Set CSS for the control border.
    var controlUI = document.createElement('div');
    controlUI.style.backgroundColor = 'white';
    controlUI.style.borderStyle = 'solid';
    controlUI.style.borderWidth = '1px';
    controlUI.style.borderColor = '#717b87';
    controlUI.style.cursor = 'pointer';
    controlUI.style.textAlign = 'center';
    controlUI.style.boxShadow = '0px 2px 4px rgba(0,0,0,0.4)';
    controlUI.style.height = '150px';
    controlUI.style.width = '200px';
    controlUI.style.top = '10px';
    controlDiv.appendChild(controlUI);

    var divA = document.createElement('div');
    divA.style.position = 'absolute';
    divA.style.top = '20px';
    divA.style.left = '15px';

    var strTable = ""
	
	if(market_flg){
		// マーケットシェア用のラベル
	    strTable = strTable + '<label style="font-size:small;"><input type="checkbox" id="marketBuildingChk"  onClick="javascript:dips_market_building_layer(marketBuildingChk.checked);" />&nbsp;&nbsp;マーケット物件</label>'
	    strTable = strTable + '<label style="font-size:small;"><input type="checkbox" id="biruBuildingChk"  onClick="javascript:dips_biru_building_layer(biruBuildingChk.checked);" />&nbsp;&nbsp;ビル管理　物件</label>'
	}else{
		// 管理物件確認用
	    strTable = strTable + '<label style="font-size:small;"><input type="checkbox" id="ownerChk"  onClick="javascript:dips_owners(ownerChk.checked);" />&nbsp;&nbsp;貸主マーカー</label>'
	    strTable = strTable + '<label style="font-size:small;"><input type="checkbox" id="trustChk" onClick="javascript:dips_trusts(trustChk.checked);" />&nbsp;&nbsp;委託契約ライン</label>'
	}
	
    strTable = strTable + '<label style="font-size:small;margin-bottom:0px;padding-bottom:0px;clear:both;"><input type="checkbox" id="shopChk" onClick="javascript:dips_shops(shopChk.checked);" checked/>&nbsp;&nbsp;営業所マーカー</label>'
    strTable = strTable + '<table>'
    strTable = strTable + '<tr><td><label style="font-size:small;margin-bottom:0px;padding-bottom:0px;float:left;margin-left:15px;"><input type="checkbox" name="dispcheck01" id="circle01Chk" onClick="javascript:disp_shop_01(circle01Chk.checked);" />&nbsp;&nbsp;半径  1Km</label></td></tr>'
    strTable = strTable + '<tr><td><label style="font-size:small;margin-bottom:0px;padding-bottom:0px;float:left;margin-left:15px;"><input type="checkbox" name="dispcheck02" id="circle02Chk" onClick="javascript:disp_shop_02(circle02Chk.checked);" />&nbsp;&nbsp;半径1.2Km</label></td></tr>'
    strTable = strTable + '</table>'
	
    strTable = strTable + '</div>'  
    divA.innerHTML = strTable
    controlDiv.appendChild(divA);

    return controlDiv;
   
}


function MarketControll(map) {

    var controlDiv = document.createElement('div');
    controlDiv.index = 1;
    controlDiv.style.padding = '5px';
    controlDiv.style.marginRight = '10px';

    // Set CSS for the control border.
    var controlUI = document.createElement('div');
    controlUI.style.backgroundColor = 'white';
    controlUI.style.borderStyle = 'solid';
    controlUI.style.borderWidth = '1px';
    controlUI.style.borderColor = '#717b87';
    controlUI.style.cursor = 'pointer';
    controlUI.style.textAlign = 'center';
    controlUI.style.boxShadow = '0px 2px 4px rgba(0,0,0,0.4)';
    controlUI.style.height = '380px';
    controlUI.style.width = '200px';
    controlUI.style.top = '10px';
    controlDiv.appendChild(controlUI);

    var divA = document.createElement('div');
    divA.style.position = 'absolute';
    divA.style.top = '20px';
    divA.style.left = '15px';

    var strTable = ""
    strTable = strTable + '<label style="font-size:small;"><input type="checkbox" id="marketShareChk"  onClick="javascript:dips_market_share_layer( );" />&nbsp;&nbsp;マーケットシェア表示</label>'
    strTable = strTable + '<hr style="border:none;border-top:dashed 1px #CCCCCC;height:1px;color:#FFFFFF;margin:0;padding:0;margin-bottom:10px;margin-right:15px;">'

    strTable = strTable + '<label style="font-size:small;">対象エリア</label>'
    strTable = strTable + '<div>'
    strTable = strTable + '<label class="checkbox-inline"><input type="radio" name="market_area" id="market_area_01" value="radio1" onchange="dips_market_share_layer();" checked>&nbsp;&nbsp;全て</label>'
    strTable = strTable + '<label class="checkbox-inline" style="padding:0;"><input type="radio" name="market_area" id="market_area_02" value="radio2" onchange="dips_market_share_layer();">&nbsp;&nbsp;重点</label>'
    strTable = strTable + '<label class="checkbox-inline" style="padding:0;"><input type="radio" name="market_area" id="market_area_03" value="radio3" onchange="dips_market_share_layer();">&nbsp;&nbsp;準重点</label>'
    strTable = strTable + '</div>'
    strTable = strTable + '<label style="font-size:small;margin-top:10px;">シェア種別</label>'
    strTable = strTable + '<div>'
    strTable = strTable + '<label class="checkbox-inline"><input type="radio" name="share_kind" id="share_kind_01" value="radio1" onchange="dips_market_share_layer();" checked>&nbsp;&nbsp;&nbsp;戸数</label>'
    strTable = strTable + '<label class="checkbox-inline"><input type="radio" name="share_kind" id="share_kind_02" value="radio2" onchange="dips_market_share_layer();">&nbsp;&nbsp;&nbsp;棟数</label>'
    strTable = strTable + '</div>'
	
	
    strTable = strTable + '<table class="brwsr1" style="font-size: 12px;border-collapse: separate;border-spacing: 0px 1px;width:150px;margin-top:15px;margin-left:10px;">'
    strTable = strTable + '    <tbody>'
    strTable = strTable + '        <tr><td style="padding: 5px;vertical-align: middle;text-align: center;border-bottom: #999 1px solid;font-size: 11px;color: #fff;background: #FF0000;" >上位目標値以上</td><td style="color: #fff;background: #FF0000;border-bottom: #999 1px solid;" >19.3%</td></tr>'
    strTable = strTable + '        <tr><td style="padding: 5px;vertical-align: middle;text-align: center;border-bottom: #999 1px solid;font-size: 11px;color: #fff;background: #ff8000;" >影響目標値</td><td style="color: #fff;background: #ff8000;border-bottom: #999 1px solid;">10.9%</td></tr>'
    strTable = strTable + '        <tr><td style="padding: 5px;vertical-align: middle;text-align: center;border-bottom: #999 1px solid;font-size: 11px;color: #000;background: #33ff77;" >存在目標値</td><td style="color: #000;background: #33ff77;border-bottom: #999 1px solid;">6.8%</td></tr>'
    strTable = strTable + '        <tr><td style="padding: 5px;vertical-align: middle;text-align: center;border-bottom: #999 1px solid;font-size: 11px;color: #000;background: #4dffff;" >拠点目標値</td><td style="color: #000;background: #4dffff;border-bottom: #999 1px solid;">2.8%</td></tr>'
    strTable = strTable + '        <tr><td style="padding: 5px;vertical-align: middle;text-align: center;border-bottom: #999 1px solid;font-size: 11px;color: #000;background: #cccccc;" colspan="2">拠点目標未満</td></tr>'
    strTable = strTable + '        <tr><td style="padding: 5px;vertical-align: middle;text-align: center;border-bottom: #999 1px solid;font-size: 11px;color: #fff;background: #0000FF;" colspan="2">算出不能</td></tr>'
    strTable = strTable + '    </tbody>'
    strTable = strTable + '</table>'
	
    divA.innerHTML = strTable
    controlDiv.appendChild(divA);

    return controlDiv;
   
}


function ResultControll(map) {

    var controlDiv = document.createElement('div');
    controlDiv.index = 1;
    controlDiv.style.padding = '5px';
    controlDiv.style.marginRight = '10px';

    // Set CSS for the control border.
    var controlUI = document.createElement('div');
    controlUI.style.backgroundColor = 'white';
    controlUI.style.borderStyle = 'solid';
    controlUI.style.borderWidth = '1px';
    controlUI.style.borderColor = '#717b87';
    controlUI.style.cursor = 'pointer';
    controlUI.style.textAlign = 'center';
    controlUI.style.boxShadow = '0px 2px 4px rgba(0,0,0,0.4)';
    controlUI.style.height = '40px';
    controlUI.style.width = '200px';
    controlUI.style.top = '10px';
    controlDiv.appendChild(controlUI);

    var divA = document.createElement('div');
    divA.style.position = 'absolute';
    divA.style.top = '15px';
    divA.style.left = '15px';

    var strTable = "";
    strTable = strTable + '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a href="javascript:win_result_biru();"><span style="font-size:small;">建物</span></a>';
    strTable = strTable + '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a href="javascript:win_result_owner();"><span style="font-size:small">貸主</span></a>';
    strTable = strTable + '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a href="javascript:win_result_shop();"><span style="font-size:small;">営業所</span></a>';

    divA.innerHTML = strTable
    controlDiv.appendChild(divA);

    return controlDiv;

}



function StreetViewControll(map) {
    var controlDiv = document.createElement('div');
    controlDiv.index = 1;
    controlDiv.style.padding = '5px';
    controlDiv.style.marginBottom = '5px';
    controlDiv.style.marginLeft = '50px';

    // Set CSS for the control border.
    var controlUI = document.createElement('div');
    controlUI.style.backgroundColor = 'yellow';
    controlUI.style.borderStyle = 'solid';
    controlUI.style.borderWidth = '1px';
    controlUI.style.borderColor = '#717b87';
    controlUI.style.cursor = 'pointer';
    controlUI.style.textAlign = 'center';
    controlUI.style.boxShadow = '0px 1px 4px rgba(1,0,0,0.4)';
    controlDiv.appendChild(controlUI);

    // Set CSS for the control interior.
    var controlText = document.createElement('div');
    controlText.style.fontFamily = 'Arial,sans-serif';
    controlText.style.fontSize = '13px';
    controlText.style.paddingTop = '5px';
    controlText.style.paddingBottom = '5px';
    controlText.style.paddingLeft = '10px';
    controlText.style.paddingRight = '10px';
    controlText.innerHTML = '<strong>ストリートビュー&nbsp;&nbsp;表示</strong>';
    controlUI.appendChild(controlText);

    var fullScreen = false;
    var mapDiv = map.getDiv();

    // Setup the click event listener
    google.maps.event.addDomListener(controlUI, 'click', function() {
//      if (!fullScreen) {
      if (document.getElementById("panowide").style.display == "none") {
        street_veiw_window();
        refresh_view(panorama.getPosition());

        controlText.innerHTML = '<strong>ストリートビュー非表示</strong>';
      }
      else {
        init_display()
        controlText.innerHTML = '<strong>ストリートビュー&nbsp;&nbsp;表示</strong>';
      }
      fullScreen = !fullScreen;
    });

    return controlDiv;
}


function GoogleMessageControll(map) {
    var controlDiv = document.createElement('div');
    controlDiv.index = 1;
    controlDiv.style.padding = '0px';
    controlDiv.style.marginBottom = '0px';
    controlDiv.style.marginLeft = '0px';

    // Set CSS for the control border.
    var controlUI = document.createElement('div');
    controlUI.style.cursor = 'pointer';
    controlUI.style.textAlign = 'center';
	
    controlDiv.appendChild(controlUI);

    // Set CSS for the control interior.
    var controlText = document.createElement('div');
    controlText.style.fontFamily = 'Arial,sans-serif';
    controlText.style.fontSize = '18px';
    controlText.style.paddingTop = '0px';
    controlText.style.paddingBottom = '0px';
    controlText.style.paddingLeft = '10px';
    controlText.style.paddingRight = '0px';
    controlText.style.marginTop = '0px';
    controlText.style.marginBottom = '0px';
    controlText.style.marginLeft = '0px';
    controlText.style.marginRight = '0px';
    controlText.innerHTML = '<strong>↓↓Googleのページへ連動します</strong>';
    controlUI.appendChild(controlText);

    return controlDiv;
}

// 変換用配列などを作成します。
function init_process(){

  // 営業所IDを添字、営業所CODEを値に変換用配列を作成します。。
  gon.all_shops.forEach(function(shop){
      convert_shop[shop.id] = parseInt(shop.code);
  });
}

// ストリートビューを非表示にして map_canvasの高さを設定
function init_display(){
	
	if (street_vew_vertical == true){
  	  document.getElementById("map_canvas").style.height = "100%";
  	  document.getElementById("map_canvas").style.width = "80%";
	  
  	  document.getElementById("panowide").style.height = "0px";
  	  document.getElementById("panowide").style.width = "0px";
  	  document.getElementById("panowide").style.display = "none";
		
	} else{
	  document.getElementById("map_canvas").style.height = "100%";
	  document.getElementById("panowide").style.height = "0px";
	  document.getElementById("panowide").style.display = "none";
		
	}
	
}

// ストリートビューの表示を設定します。
function street_veiw_window(){
	
	if (street_vew_vertical == true){
	    document.getElementById("map_canvas").style.width = "40%";
	    document.getElementById("map_canvas").style.height = "100%";
		
	    document.getElementById("panowide").style.width = "40%";
	    document.getElementById("panowide").style.height = "100%";
	    document.getElementById("panowide").style.display = "block";
		
	}else{
	    document.getElementById("map_canvas").style.height = "50%";
	    document.getElementById("panowide").style.height = "50%";
	    document.getElementById("panowide").style.display = "block";
	}
}


// 管理委託契約と建物・貸主の紐付け（このように関数で呼び出すようにする必要がある）
function create_relation_listener(trust_ev, owner_ev, build_ev){

  // 貸主マーカーにて委託契約ONのイベント
  google.maps.event.addDomListener(owner_ev, "trust_on", function(){
    trust_ev.set("visible", true);
    build_ev.set("visible", true);
  });

  // 貸主マーカーにて委託契約OFFのイベント
  google.maps.event.addDomListener(owner_ev, "trust_off", function(){
    trust_ev.set("visible", false);
    build_ev.set("visible", false);
  });

  // 建物マーカーにて委託契約ONのイベント
  google.maps.event.addDomListener(build_ev, "trust_on", function(){
    trust_ev.set("visible", true);
    owner_ev.set("visible", true);
  });

  // 建物マーカーにて委託契約OFFのイベント
  google.maps.event.addDomListener(build_ev, "trust_off", function(){
    trust_ev.set("visible", false);
    owner_ev.set("visible", false);
  });

}


// ストリートビューを表示
function view_disp(disp_flg, lat, lng){

    if(disp_flg == true){
      // ストリートビュー　表示設定
      street_veiw_window();
      refresh_view(new google.maps.LatLng(lat,lng));

    }else{
      // ストリートビューを非表示に設定
      init_display();
    }
	
}

/* ストリートビューのリフレッシュ */
function refresh_view(pos){
    // ストリートビューがないところを一度選択するとそれ以降他もも表示されなくなるので、再度生成する。
    panorama = new  google.maps.StreetViewPanorama(document.getElementById("panowide"), panoramaOptions);
    panorama.setPosition(pos);
    panorama.setPov(panoramaOptions.pov);
    mapCanvas.setStreetView(panorama);
}

// ストリートビューを閉じます
function sv_init(){
    init_display();
}

// 円を描きます
function create_circle(size, mapCanvas, pos){
  var myCircle = new google.maps.Circle({
    map : mapCanvas
    ,center : pos
    ,strokeColor: 'blue' /* ストロークの色 */
    ,strokeOpacity: 0.9 /* ストロークの透明度 */
    ,strokeWeight: 1 /* ストロークの幅 */
    ,fillColor: 'blue' /* フィルの色 */
    ,fillOpacity: 0.1 /* フィルの透明度 */
	//,draggable: true  /* ドラッグ可能 */
	//,editable: true  /* 編集可能 */
  });

  myCircle.setRadius(size); // メートル単位で指定
  myCircle.set("visible",false);

  return myCircle
}

/* マーカーを作成 */
function createMarker(opts){
  var marker = new google.maps.Marker(opts);

  google.maps.event.addListener(marker, "click", function(){
    // write_build(opts.info_msg);

    infoWnd.close();
    infoWnd.setContent(opts.html);
    infoWnd.open(opts.map, marker);
    opts.map.panTo(opts.position);

    marker.set("visible", true);

	// ストリートビュー用の領域を定義している時のみ処理
	if(document.getElementById("panowide") != null){
	    if(document.getElementById("panowide").style.display != "none"){
	      refresh_view(opts.position);
	    }
	}

  });

  return marker;
}

// 地図の初期設定を行います。
function init_map(user_id, search_bar_disp_flg, market_bar_disp_flg){

    /* 地図を作成 */
    var mapDiv = document.getElementById("map_canvas");
    mapCanvas = new google.maps.Map(mapDiv, {
		// 画面左上の地図レイアウト（写真とか文字なしとか）　不要になったため削除　2016.03.22 del-start
		// mapTypeControlOptions: {
		// 	        mapTypeIds: [google.maps.MapTypeId.ROADMAP,'noText', 'map_style','noText2', 'noRoad']
		// },
		// 画面左上の地図レイアウト（写真とか文字なしとか）　不要になったため削除　2016.03.22 del-end
      scaleControl: true
      ,minZoom:2
    });
		
		
//    // Create an array of styles.
//    var styledMap = new google.maps.StyledMapType(
//	    [
//	      {
//	        stylers: [
//	          { hue: "#00ffe6" },
//	          { saturation: -20 }
//	        ]
//	      },{
//	        featureType: "road",
//	        elementType: "geometry",
//	        stylers: [
//	          { lightness: 100 },
//	          { visibility: "simplified" }
//	        ]
//	      },{
//	        featureType: "road",
//	        elementType: "labels",
//	        stylers: [
//	          { visibility: "off" }
//	        ]
//	      }
//	    ]
//		, {name: "Styled Map"}
//	);	
//	mapCanvas.mapTypes.set('map_style', styledMap);	
//	mapCanvas.setMapTypeId('map_style');
//		


// // 画面左上の地図レイアウト（写真とか文字なしとか）　不要になったため削除　2016.03.22 del-start
// 	// スタイル定義(文字なし)
// 	var lopanType = new google.maps.StyledMapType(
// 		[
// 			{
// 				featureType: 'all'
// 			   ,elementType: 'labels'
// 			   ,stylers: [{ visibility: 'off' }]
// 			}
//
// 		]
// 		,{ name: '文字なし' }
// 	);
// 	mapCanvas.mapTypes.set('noText', lopanType);
//
//
// 	var lopanType2 = new google.maps.StyledMapType(
// 		[
//
//
// 			{
// 				featureType: 'landscape'
// 			   ,elementType: 'all'
// 			   ,stylers: [{ visibility: 'off' }]
// 			},
//
// 			{
// 				featureType: 'poi'
// 			   ,elementType: 'all'
// 			   ,stylers: [{ visibility: 'off' }]
// 			},
//
//
// 			{
// 				featureType: 'all'
// 			   ,elementType: 'labels'
// 			   ,stylers: [{ visibility: 'off' }]
// 			}
//
//
// 		]
// 		,{ name: '文字なし２' }
// 	);
// 	mapCanvas.mapTypes.set('noText2', lopanType2);
//
// 	var lopanType3 = new google.maps.StyledMapType(
// 		[
//
// 			{
// 				featureType: 'road.local'
// 			   ,elementType: 'all'
// 			   ,stylers: [{ visibility: 'off' }]
// 			},
//
// 			{
// 				featureType: 'landscape'
// 			   ,elementType: 'all'
// 			   ,stylers: [{ visibility: 'off' }]
// 			},
//
// 			{
// 				featureType: 'poi'
// 			   ,elementType: 'all'
// 			   ,stylers: [{ visibility: 'off' }]
// 			},
//
//
// 			{
// 				featureType: 'all'
// 			   ,elementType: 'labels'
// 			   ,stylers: [{ visibility: 'off' }]
// 			}
//
//
// 		]
// 		,{ name: '文字なし・細い道路なし' }
// 	);
// 	mapCanvas.mapTypes.set('noRoad', lopanType3);
// // 画面左上の地図レイアウト（写真とか文字なしとか）　不要になったため削除　2016.03.22 del-end
	
		
	
    if(search_bar_disp_flg == true){
    	
	    // フルスクリーンラベルを設定
	    // mapCanvas.controls[google.maps.ControlPosition.TOP_LEFT].push(new FullScreenControl(mapCanvas));
		
		if(market_bar_disp_flg == true){
			
			// 市場シェア率
		    mapCanvas.controls[google.maps.ControlPosition.LEFT_BOTTOM].push(new GoogleMessageControll(mapCanvas));
		    mapCanvas.controls[google.maps.ControlPosition.LEFT_BOTTOM].push(new StreetViewControll(mapCanvas));
		    mapCanvas.controls[google.maps.ControlPosition.RIGHT_CENTER].push(new MarketControll(mapCanvas));
		    mapCanvas.controls[google.maps.ControlPosition.RIGHT_CENTER].push(new DispControll(mapCanvas, true));
			
		}else{
			// 通常の管理物件情報
		    mapCanvas.controls[google.maps.ControlPosition.TOP_RIGHT].push(new MenuControll(mapCanvas));
		    mapCanvas.controls[google.maps.ControlPosition.LEFT_BOTTOM].push(new GoogleMessageControll(mapCanvas));
		    mapCanvas.controls[google.maps.ControlPosition.LEFT_BOTTOM].push(new StreetViewControll(mapCanvas));
		    mapCanvas.controls[google.maps.ControlPosition.RIGHT_CENTER].push(new BarControll(mapCanvas, user_id));
		    mapCanvas.controls[google.maps.ControlPosition.RIGHT_CENTER].push(new DispControll(mapCanvas, false));
		    mapCanvas.controls[google.maps.ControlPosition.RIGHT_CENTER].push(new ResultControll(mapCanvas));
		}

    }
	 

    /*----------------------------------------------------------------------*/
    /* ストリートビューオブジェクトを作成 （これはcreate markerを呼び出す前に定義する。）*/
    /*----------------------------------------------------------------------*/
    panoramaOptions = {
      position:mapCanvas.getCenter(),
      pov:{heading: 180,pitch:0,zoom:0},
	  //enableCloseButton: true,
	  addressControlOptions: {
	      position: google.maps.ControlPosition.BOTTOM
	  }
    };
    panorama = new  google.maps.StreetViewPanorama(document.getElementById("panowide"), panoramaOptions);

    mapCanvas.setStreetView(panorama);
    google.maps.event.addListener(panorama, 'position_changed', function()
    {
      var positionPegman = panorama.getPosition();

      // ストリートビューが表示されていなかったら表示
      if( document.getElementById("panowide").style.display == "none" ){
        view_disp(true, positionPegman.latitude, positionPegman.longitude);
      }

      //ペグマン位置変更イベント
      mapCanvas.panTo(positionPegman);
    });

    // infoウィンドウを１つだけ作成
    infoWnd = new google.maps.InfoWindow();


  return mapCanvas;
}

// 引数 close_windowは未指定でもOK
function win_owner(id, close_window) {
  var str_url;
  
  if(close_window == null){
  	str_url = '/biruweb/managements/popup_owner/' + id
  }else{
  	str_url = '/biruweb/managements/popup_owner/' + id + '?close=' + close_window
  }
  
  window.open(str_url   , "", "width=1000,height=1000,resizable=yes,scrollbars=yes,location=no");
}


function win_popup_owner_create() {
  window.open('/biruweb/trust_managements/popup_owner_create'  , "", "width=1000,height=1000,resizable=yes,scrollbars=yes,location=no");
}


function win_building(id){
  window.open('/biruweb/managements/popup_building/' + id   , "", "width=1000,height=850,resizable=yes,scrollbars=yes");
}

function win_user(id){
  window.open('/biruweb/trust_managements/trust_user_report?sid=' + id   , "", "width=1000,height=1500,resizable=yes,scrollbars=yes,location=no");
}

function win_picture(id){
  window.open('/biruweb/renters/pictures?id=' + id   , "", "width=1000,height=1500,resizable=yes,scrollbars=yes,location=no");
}

function win_trust_report(user_id, month){
    window.open('/biruweb/trust_managements/trust_user_report?sid=' + user_id + '&month=' + month , "", "width=1500,height=1100,resizable=yes,scrollbars=yes,location=no");
}

function win_attack_list_maintenance(user_id){
    window.open('/biruweb/trust_managements/attack_list_maintenance?sid=' + user_id   , "", "width=1000,height=1500,resizable=yes,scrollbars=yes,location=no");
}

function win_attack_list_maintenance_bulk(user_id){
    window.open('/biruweb/trust_managements/attack_list_maintenance_bulk?sid=' + user_id   , "", "width=500,height=500,resizable=yes,scrollbars=yes,location=no");
}


// 委託CDの紐付けを行います
function trust_create(owner_id, building_id, biru_user_id){
	if(window.confirm('紐付けを行います。よろしいですか？')){
		location.href = '/biruweb/trust_managements/create_trust?owner_id=' + owner_id + '&building_id=' + building_id + '&biru_user_id=' + biru_user_id
	}
}

// 委託CDの紐付け解除を行います。
function trust_delete(trust_id, biru_user_id){
	if(window.confirm('指定の物件の紐付け解除を行います。よろしいですか？')){
		location.href = '/biruweb/trust_managements/delete_trust?trust_id=' + trust_id + '&biru_user_id=' + biru_user_id
	}
}



function screen_block(){
  //$.blockUI({ message: '検索中…しばらくお待ちください'});
  $('#body-contents').block({
    message: '検索中...しばらくおまちください',
    fadeIn: 200,
    fadeOut: 0,
    css: {
        padding: '15px 0 0 0',
        margin: 0,
        height: '50px',
        width: '250px',
        border: '2px solid #aaa',
    }
  });
	
}


function screen_unblock(){
  //$.blockUI({ message: '検索中…しばらくお待ちください'});
  $('#body-contents').unblock();
	
}

// 建物のInfoBoxを登録する。
function info_msg_biru(biru, owners){
  var inner_text = "";
  var vhtml;
  var code_msg;

  if(biru.code != null){
    // 通常建物CDの時
    code_msg = "建物CD：" + biru.code;
  }else{
    // 他社建物CDの時
    code_msg = "他社建物CD：" + biru.code;
  }
  
  owners.forEach(function(owner){
    inner_text = inner_text +
      '<li>' +
      '  <a href="javascript:link_owner_click(' + owner.id + ',' + owner.latitude + ',' + owner.longitude + ')">' + owner.name + '</a>' +
      '</li>'
  });

  vhtml = '<div><b>' + biru.name + '（<a href="javascript:win_building(' + biru.id + ');">詳細</a>）</b><br>' +
    '<div>' + code_msg +'</div>' +
    '<ul style="padding-top:10px;">' + inner_text  + '</ul>' +
    '<hr/>' +
    '<div style="padding-top:0px;margin-top:0px;padding-left:10px;float:left;">' +
    '  <label><input type="checkbox" onclick="this.blur();this.focus();" onchange="building_trust_disp(' + biru.id  + ', this.checked);" />&nbsp;委託</label>' +
    '</div>' +
    '<div style="padding-top:0px;margin-top:0px;padding-left:10px;float:left;">' +
    '  <label><input type="checkbox" onclick="this.blur();this.focus();" onchange="view_disp( this.checked, ' + biru.latitude + ',' + biru.longitude  + '); return false;" />&nbsp;ストリートビュー</label>' +
    '</div>' +
    '</div>';

  return vhtml;

}


// 貸主のInfoBoxのメッセージを作成する。
function info_msg_owner(owner, buildings){

  var code_msg;
  if(owner.code != null){
    // 通常建物CDの時
    code_msg = "貸主CD：" + owner.code;
  }else{
    // 他社建物CDの時
    code_msg = "他社貸主CD：" + owner.code;
  }

  var inner_text = "";
  	
  buildings.forEach(function(building){
    inner_text = inner_text +
      '<li>' +
      '  <a href="javascript:link_building_click(' + building.id + ',' + building.latitude + ',' + building.longitude + ')">' + building.name + '</a>' +
      '</li>'
  });

  var vhtml = '<div><b>' + owner.name + '（<a href="javascript:win_owner(' + owner.id + ');">詳細</a>）</b><br>' +
    '<div>' + code_msg +'</div>' +
    '<ul style="padding-top:10px;">' + inner_text  + '</ul>' +
    '<hr/>' +
    '<div style="padding-top:0px;margin-top:0px;padding-left:10px;float:left;">' +
    '  <label><input type="checkbox" onclick="this.blur();this.focus();" onchange="owner_trust_disp(' + owner.id  + ', this.checked);" />&nbsp;委託</label>' +
    '</div>' +
    '<div style="padding-top:0px;margin-top:0px;padding-left:10px;float:left;">' +
    '  <label><input type="checkbox" onclick="this.blur();this.focus();" onchange="view_disp( this.checked, ' + owner.latitude + ',' + owner.longitude  + '); return false;" />&nbsp;ストリートビュー</label>' +
    '</div>' +
    '</div>';

  return vhtml;
}


// infoWindowで委託ライン有無を押下された時に動作します。(貸主)
function owner_trust_disp(id, flg){
  if(flg == true){
   google.maps.event.trigger(owner_arr[id], "trust_on");
  }else{
   google.maps.event.trigger(owner_arr[id], "trust_off");
  }
}

// infoWindowで委託ライン有無を押下された時に動作します。(建物)
function building_trust_disp(id, flg){
  if(flg == true){
   google.maps.event.trigger(build_arr[id], "trust_on");
  }else{
   google.maps.event.trigger(build_arr[id], "trust_off");
  }
}

// 建物リンクをクリックした時の動きを定義します。
function link_building_click(num, lat, lng)
{
  mapCanvas.setZoom(18);
  google.maps.event.trigger(build_arr[num], "click");
}

// 貸主リンクをクリックした時の動きを定義します。
function link_owner_click(num, lat, lng)
{
  mapCanvas.setZoom(18);
  google.maps.event.trigger(owner_arr[num], "click");
}

// 営業所リンクをクリックした時の動きを定義します。
function link_shop_click(num)
{
  mapCanvas.setZoom(18);
  google.maps.event.trigger(shop_arr[num], "click");
}

// 貸主とそれに紐づく物件をポリラインで結んだ者を表示します。
function link_owner_trusts_click(trust_num, building_num, owner_num)
{
	// trustに紐づくオーナーを取得
	trust_arr[trust_num].set("visible", true);
	build_arr[building_num].set("visible", true);
	owner_arr[owner_num].set("visible", true);
	
    var bounds_local = new google.maps.LatLngBounds();
    bounds_local.extend(build_arr[building_num].position);
    bounds_local.extend(owner_arr[owner_num].position);
    mapCanvas.fitBounds(bounds_local);
	
	google.maps.event.trigger(build_arr[building_num], "click");
	mapCanvas.setZoom(mapCanvas.getZoom()-1);
}



function sel_itaku_owner(obj, id){
  obj_value = obj.options[obj.selectedIndex].value;
  if(obj_value == "on"){
    owner_trust_disp(id, true);
  }else{
    owner_trust_disp(id, false);
  }
}

function sel_itaku_building(obj, id){
  obj_value = obj.options[obj.selectedIndex].value;
  if(obj_value == "on"){
    building_trust_disp(id, true);
  }else{
    building_trust_disp(id, false);
  }
}

function sel_view(obj, lat, lng){
  obj_value = obj.options[obj.selectedIndex].value;
  if(obj_value == "on"){
    view_disp(true, lat, lng);
  }else{
    view_disp(false, lat, lng);
  }
}

// 管理方式のICONを返します。
function get_manage_icon(manage_id){
  switch(manage_id){
    case 1:
      break;
    default:
      break;
  }
}

// 営業所のInfoBoxを登録する。
function info_msg_shop(shop){
  var vhtml;

  vhtml = '<div><b>' + shop.name + '</b></div>' +
    '<div> TEL1：' + shop.tel +'</div>' +
    '<div> TEL2：' + shop.tel2 +'</div>' +
    '<div>定休日：' + shop.holiday +'</div>'

  return vhtml;
}

/**
 *  ブラウザ名を取得
 *  
 *  @return     ブラウザ名(ie6、ie7、ie8、ie9、ie10、ie11、chrome、safari、opera、firefox、unknown)
 *
 */
var getBrowser = function(){
    var ua = window.navigator.userAgent.toLowerCase();
    var ver = window.navigator.appVersion.toLowerCase();
    var name = 'unknown';

    if (ua.indexOf("msie") != -1){
        if (ver.indexOf("msie 6.") != -1){
            name = 'ie6';
        }else if (ver.indexOf("msie 7.") != -1){
            name = 'ie7';
        }else if (ver.indexOf("msie 8.") != -1){
            name = 'ie8';
        }else if (ver.indexOf("msie 9.") != -1){
            name = 'ie9';
        }else if (ver.indexOf("msie 10.") != -1){
            name = 'ie10';
        }else{
            name = 'ie';
        }
    }else if(ua.indexOf('trident/7') != -1){
        name = 'ie11';
    }else if (ua.indexOf('chrome') != -1){
        name = 'chrome';
    }else if (ua.indexOf('safari') != -1){
        name = 'safari';
    }else if (ua.indexOf('opera') != -1){
        name = 'opera';
    }else if (ua.indexOf('firefox') != -1){
        name = 'firefox';
    }
    return name;
};


/**
 *  対応ブラウザかどうか判定
 *  
 *  @param  browsers    対応ブラウザ名を配列で渡す(ie6、ie7、ie8、ie9、ie10、ie11、chrome、safari、opera、firefox)
 *  @return             サポートしてるかどうかをtrue/falseで返す
 *
 */
var isSupported = function(browsers){
    var thusBrowser = getBrowser();
    for(var i=0; i<browsers.length; i++){
        if(browsers[i] == thusBrowser){
            return true;
            // exit; 2017/05/07 shibata 不要の為削除
        }
    }
    return false;
};




// jqgridのテーブルを作成します。
// 1:tableのid名
// 2:fotterのid
// 3:表示するテーブルの所属するdiv名
// 4:列名リスト
// 5:列モデル
// 6:キャプション
// 7:イベント種別 1:shop, 2:building, 3:owner 30:trust_manage用のowner 31:renters用のbuilding_id
// 8:画面サイズを自動的にフィットさせるか
function jqgrid_create(col_names, col_model, data_list, jqgrid_opt){
	
	var table_div = $('#' + jqgrid_opt.table_name);
	var div_box = $('#' + jqgrid_opt.div_name);
	
	table_div.jqGrid({
	  	data : data_list,  //表示したいデータ
	  	datatype : "local",            //データの種別 他にjsonやxmlも選べます。しかし、私はlocalが推奨です。
	  	colNames : col_names,           //列の表示名
	  	colModel : col_model,   //列ごとの設定
	  	rowNum : 100,                   //一ページに表示する行数
	  	rowList : [100, 100000],         //変更可能な1ページ当たりの行数
	  	caption : jqgrid_opt.caption,    //ヘッダーのキャプション
		loadComplete : function () {  // 幅の%調整。読み込みが完了したあと指定のdivの幅と高さを%でとってきて設定
			table_div.jqGrid('setGridWidth', div_box.width(), jqgrid_opt.shrinkFit);
		    table_div.jqGrid('setGridHeight', div_box.height(), jqgrid_opt.shrinkFit);
		},
        onSelectRow: function(id) {
           // idにはリストの選択した行番号が入ってくる
		   
		   if(jqgrid_opt.event_type == 1 ){
			   link_shop_click(table_div.getRowData(id).id);
		   }else if(jqgrid_opt.event_type == 2){
			   link_building_click(table_div.getRowData(id).id);
		   }else if(jqgrid_opt.event_type == 30){
			   link_owner_click(table_div.getRowData(id).owner_id);
		   }else if(jqgrid_opt.event_type == 31){
			   link_building_click(table_div.getRowData(id).renters_building_id);
		   }else if(jqgrid_opt.event_type == 32){
			   link_building_click(table_div.getRowData(id).building_id);
		   }else if(jqgrid_opt.event_type == 33){
			   link_owner_trusts_click(table_div.getRowData(id).trust_id, table_div.getRowData(id).building_id, table_div.getRowData(id).owner_id);
		   }else if(jqgrid_opt.event_type == 40){
			   link_building_click(table_div.getRowData(id).building_id);
		   }
		   
        },
	  	pager : jqgrid_opt.fotter_name,              //footerのページャー要素のid
	  	shrinkToFit : false,　　        //画面サイズに依存せず固定の大きさを表示する設定
		multiselect: jqgrid_opt.multiselect,
	  	viewrecords: true              //footerの右下に表示する。
	});
  
	//   //検索追加
	// table_div.jqGrid('navGrid',('#' + fotter_name),{
	// 	add:false,   //おまじない
	// 	edit:false,  //おまじない
	// 	del:false,   //おまじない
	// 	search:{     //検索オプション
	// 	odata : ['equal', 'not equal', 'less', 'less or equal',
	// 	       'greater','greater or equal', 'begins with',
	// 	       'does not begin with','is in','is not in','ends with',
	// 	       'does not end with','contains','does not contain']
	// 	}   //検索の一致条件を入れられる
	// });
  
	//filterバー追加
	table_div.filterToolbar({
		defaultSearch:'cn'     //一致条件を入れる。選択肢['eq','ne','lt','le','gt','ge','bw','bn','in','ni','ew','en','cn','nc'] 
	});		
}


function htmlEscape(str) {
    return String(str).replace(/&/g, '&')
            .replace(/"/g, '"')
            .replace(/</g, '<')
            .replace(/'/g, "'")
            .replace(/>/g, '>');

}


// 表示
function dips_circle_ttcd(sql, strType){
    // Builds a Fusion Tables SQL query and hands the result to  dataHandler
    var queryUrlHead = 'https://www.googleapis.com/fusiontables/v1/query?sql=';
    var queryUrlTail = '&key=AIzaSyCFmLUX03pHtnUN_wP2fh9rNKoOnzrCcTs';

    // write your SQL as normal, then encode it
    var queryurl = encodeURI(queryUrlHead + sql + queryUrlTail);


	// ↓　コールバック処理で、functionを拡張 var jqxhr = $.get(queryurl, dataHandler, "jsonp");
    var jqxhr = $.get(queryurl, function(resp){ 
	
		if(resp.rows != undefined){
			// 棟数の登録
		    for (var i = 0; i < resp.rows.length; i++) {
		        for (var j = 0; j < resp.rows[i].length; j++) {
					console.log(strType + ',' +resp.rows[i][j]);
		        }
		    }
			
		}
	
	 }, "jsonp");
	
}


// 参考：http://jsfiddle.net/odi86/Sbt2P/ 2016/06/06
function getFusionTableData(sql, tou_id, ko_id) {
    // Builds a Fusion Tables SQL query and hands the result to  dataHandler
    var queryUrlHead = 'https://www.googleapis.com/fusiontables/v1/query?sql=';
    var queryUrlTail = '&key=AIzaSyCFmLUX03pHtnUN_wP2fh9rNKoOnzrCcTs';

    // write your SQL as normal, then encode it
    var queryurl = encodeURI(queryUrlHead + sql + queryUrlTail);

	// ↓　コールバック処理で、functionを拡張 var jqxhr = $.get(queryurl, dataHandler, "jsonp");
    var jqxhr = $.get(queryurl, function(resp){ 
	
		if(resp.rows != undefined){
			// 棟数の登録
		    var result = document.getElementById(tou_id);
			result.innerHTML = resp.rows[0][0];
			
			// 戸数の登録
		    var result = document.getElementById(ko_id);
			result.innerHTML = resp.rows[0][1];
		}

	
	    // var htmlTable = document.createElement('table');
	    // htmlTable.border = 1;
	    //
	    // var tableRow = document.createElement('tr');
	    // for (var i = 0; i < resp.columns.length; i++) {
	    //     var tableHeader = document.createElement('th');
	    //     var header = document.createTextNode(resp.columns[i]);
	    //     tableHeader.appendChild(header);
	    //     tableRow.appendChild(tableHeader);
	    //
	    // }
	    // htmlTable.appendChild(tableRow);
	    // for (var i = 0; i < resp.rows.length; i++) {
	    //     var tableRow = document.createElement('tr');
	    //     for (var j = 0; j < resp.rows[i].length; j++) {
	    //         var tableData = document.createElement('td');
	    //         var content = document.createTextNode(resp.rows[i][j]);
	    //         tableData.appendChild(content);
	    //         tableRow.appendChild(tableData);
	    //     }
	    //     htmlTable.appendChild(tableRow);
	    // }
	    // result.appendChild(htmlTable);
	
	 }, "jsonp");
}



function iss_win_keiyaku(id, syain_code){
  //window.open("http://pzazzzs032.polus.local/iss.online/Isso120/?loginId=" + syain_code + "&prmTkCd='" + id + "'"  , "rirekiKanri", "width=1000,height=900,directories=no,location=no,menubar=no,resizable=yes,scrollbars=no,status=yes,toolbar=no,left=0,top=0");

  //	var target_name = "rirekiKanri_" + Math.random().toString(36).slice(-8); // ランダム文字列（履歴をいくつでも開けるように）
  var target_name = "rirekiKanri_" ;
  var url = "http://pzazzzs032.polus.local/iss.online/Isso120/?loginId=" + syain_code + "&prmTkCd=" + id + "" 
  var wnd = window.open("" , target_name, "width=1000,height=900,directories=no,location=no,menubar=no,resizable=yes,scrollbars=no,status=yes,toolbar=no,left=0,top=0");
  var link = document.getElementById("link");
  link.target = target_name;
  link.href = url;
  link.click();
}

function iss_win_syuuri(syain_code){

  //	var target_name = "syuuriIrak_" + Math.random().toString(36).slice(-8); // ランダム文字列（履歴をいくつでも開けるように）
  var target_name = "syuuriIrak_";
  var url = "http://pzazzzs032.polus.local/iss.online/Isso110/?loginId=" + syain_code
  var wnd = window.open("" , target_name, "width=1000,height=900,directories=no,location=no,menubar=no,resizable=yes,scrollbars=no,status=yes,toolbar=no,left=0,top=0");
  var link = document.getElementById("link");
  link.target = target_name;    
  link.href = url;
  link.click();
}

// 2017.11.28 add
function iss_win_kouji_misyuu(misyuu_kbn, seikyuu_no, kouji_no, keiyaku_no, koumoku_code, syain_code){
  
    //	var target_name = "syuuriIrak_" + Math.random().toString(36).slice(-8); // ランダム文字列（履歴をいくつでも開けるように）
    var target_name = "kouji_misyuu_";
    var url = "http://pzazzzs032.polus.local/iss.web/Isso310/Edit?Kbn=" + misyuu_kbn + "&SeiNo=" + seikyuu_no + "&KoujiNo=" + kouji_no + "&KeiyakuNo=" + keiyaku_no + "&KoumokuCD=" + koumoku_code + "&SCd=" + syain_code
    var wnd = window.open("" , target_name, "width=1000,height=900,directories=no,location=no,menubar=no,resizable=yes,scrollbars=no,status=yes,toolbar=no,left=0,top=0");
    var link = document.getElementById("link");
    link.target = target_name;    
    link.href = url;
    link.click();
  }
  
  

function iss_win_building(id){
  var target_name = "win_building"
  window.open('/biruweb/managements/popup_building/' + id   , target_name, "width=1000,height=850,resizable=yes,scrollbars=yes,left=0,top=0");
}


function iss_win_owner(id, close_window) {

  var target_name = "win_owner"
  var str_url;

  if(close_window == null){
    str_url = '/biruweb/managements/popup_owner/' + id
  }else{
    str_url = '/biruweb/managements/popup_owner/' + id + '?close=' + close_window
  }

  window.open(str_url   , target_name, "width=1000,height=1000,resizable=yes,scrollbars=yes,location=no,left=0,top=0");
}

function iss_win_heya(bukken_cd, heya_cd){
  var target_name = "heya_";
  var url = "http://pzazzzs032.polus.local/biruweb/comments?comment_type=40&code=" + bukken_cd + "&sub_code=" + heya_cd
  var wnd = window.open("" , target_name, "width=1000,height=900,directories=no,location=no,menubar=no,resizable=yes,scrollbars=no,status=yes,toolbar=no,left=0,top=0");
  var link = document.getElementById("link");
  link.target = target_name;    
  link.href = url;
  link.click();
}

function iss_win_construction(kouzi_no){
  var target_name = "win_construction";
  window.open('/biruweb/constructions/popup/' + kouzi_no , target_name, "width=1000,height=850,resizable=yes,scrollbars=yes,left=0,top=0");
}

