<%@ page language="java" contentType="text/html; charset=EUC-KR"
    pageEncoding="EUC-KR"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no">
    <title>지도</title>
    <script type="text/javascript" src="http://code.jquery.com/jquery-latest.min.js"></script>
    <script type="text/javascript" src="https://openapi.map.naver.com/openapi/v3/maps.js?ncpClientId=z13sllck04"></script>
	<style>
		ul {list-style-type:none;
		padding-left:0px;
		float:right;
		}
		ul li {display:inline;
		/* li요소의 좌측 1px의 테두리 만들기 */
		border-left: 1px solid #c0c0c0;
		/* 테두리와 메뉴 간격 벌리기, padding: 위 오른쪽 아래 왼쪽; */
		padding: 0px 10px 0px 10px;
		/* 메뉴와 테두리 사이 간격 벌리기, margin: 위 오른쪽 아래 왼쪽; */
		margin: 5px 0px 5px 0px;
		}
		ul li:first-child {
		/* li의 첫번째 요소 좌측에는 테두리 없애기 */
		border-left: none;
		}
		
		.menu {
		  position : relative;
		  display : inline-block;
		}
		
		.submenu {
		  display : none;
		  position : absolute;
		  z-index : 1; /*다른 요소들보다 앞에 배치*/
		}
		
		.submenu a {
		  display : block;
		}
		
		.menu:hover .submenu {
		  display: block;
		}
	</style>

</head>
<body>
	<div>
	<ul class="menu">
		<li>
			<a href="#">id별로 보기</a>
			<ul class="submenu">
	          <li><a href="#" onclick="func1()">id = 1</a></li>
	          <li><a href="javascript:func2()">id = 2</a></li>
        	</ul>
		</li>
		<li>메뉴 2</li>
		<li>메뉴 3</li>
	</ul>
	</div>
    <div id="map" style="width:100%;height:540px;"></div>

<script>

map = new naver.maps.Map('map', {
    center: new naver.maps.LatLng(35.07480784, 129.08755334),
    zoom: 16,
    scaleControl: false,
    logoControl: false,
    mapDataControl: false,
    zoomControl: true
});

var polylinePath = [];
var polylinePath2 = [];
var latArray = [];

var idinfo = [];
var battinfo = [];
var timeinfo = [];
var idinfo2 = [];
var battinfo2 = [];
var timeinfo2 = [];

let i=0;
$(function(){
    $.ajax({
        url : "http://localhost/yhs/gpsPHP.php",
        dataType : "jsonp",
        jsonp : "callback"
    });
});



function callback(data) {
   console.log(Object.values(data));
   let len=Object.values(data).length;

   var latArray = Object.entries(data.map(row=>row.lat)); //위도 배열
   var lngArray = Object.entries(data.map(row=>row.lng)); //경도 배열
   var idArray = Object.entries(data.map(row=>row.id)); //id 배열
   var battArray = Object.entries(data.map(row=>row.batt)); //배터리 배열
   var timeArray = Object.entries(data.map(row=>row.time)); //시간 배열
   
   console.log(idArray);
   
   //id == 1
   
   for (let i=0; i<len; i++){ //위도경도 데이터 네이버 배열에 넣기
      let idStr = idArray[i].toString();
      if (idStr.split(',')[1] == "1") {
          polylinePath.push(new naver.maps.LatLng(parseFloat(latArray[i][1]), parseFloat(lngArray[i][1])));
       idinfo.push(idArray[i][1]);
       battinfo.push(battArray[i][1]);
       timeinfo.push(timeArray[i][1]);
      }
   }
   
   //경로 그리기
   var polyline = new naver.maps.Polyline({
         map: map,
            path: polylinePath,
         strokeColor: '#FF0000', //선 색 빨강
         strokeOpacity: 0.8, //선 투명도 0 ~ 1
         strokeWeight: 3   //선 두께
        });
   
   //마지막 위치에 마커 표시
   var marker = new naver.maps.Marker({
        position: polylinePath[polylinePath.length-1], //마크 표시할 위치 배열의 마지막 위치
        map: map
    });
   
   //마커 클릭 시 정보 표시
   var contentString = [
        '<div class="iw_inner">',
        '   <h3>기기 정보</h3>',
        '   <p>id: '+idinfo[idinfo.length-1].toString()+'<br />',
        '   <p>위도, 경도: '+polylinePath[polylinePath.length-1].toString()+'<br />',
        '   <p>배터리: '+battinfo[battinfo.length-1].toString()+'<br />',
        '   <p>시간: '+timeinfo[timeinfo.length-1].toString()+'<br />',
        '   </p>',
        '</div>'
    ].join('');

   var infowindow = new naver.maps.InfoWindow({
       content: contentString,
       maxWidth: 200,
       //borderColor: "#2db400",
       //borderWidth: 5,
       anchorSize: new naver.maps.Size(30, 30),
       anchorSkew: true,
       pixelOffset: new naver.maps.Point(20, -20)
   });
   
   naver.maps.Event.addListener(marker, "click", function(e) {
       if (infowindow.getMap()) {
           infowindow.close();
       } else {
           infowindow.open(map, marker);
       }
   });
   
   

   /*naver.maps.Event.addListener(id1, "click", function(e) { //id=1만 보기
	   if (polyline2.getMap(map))
    		polyline.getMap(null);
	   else
		   polyline2.getMap(map);
   });*/
   
   
   
   //id == 2
   for (let i=0; i<len; i++){ //위도경도 데이터 네이버 배열에 넣기
      let idStr = idArray[i].toString();
      if (idStr.split(',')[1] == "2") {
          polylinePath2.push(new naver.maps.LatLng(parseFloat(latArray[i][1]), parseFloat(lngArray[i][1])));
          idinfo2.push(idArray[i][1]);
       battinfo2.push(battArray[i][1]);
       timeinfo2.push(timeArray[i][1]);
      }
   }
   
   //경로 그리기
   var polyline2 = new naver.maps.Polyline({
         map: map,
            path: polylinePath2,
         strokeColor: '#00FF00', //선 초록
         strokeOpacity: 0.8, //선 투명도 0 ~ 1
         strokeWeight: 3   //선 두께
        });
   
   //마지막 위치에 마커 표시
   var marker2 = new naver.maps.Marker({
        position: polylinePath2[polylinePath2.length-1], //마크 표시할 위치 배열의 마지막 위치
        map: map
    });
   
   //마커 클릭 시 정보 표시
   var contentString = [
        '<div class="iw_inner">',
        '   <h3>기기 정보</h3>',
        '   <p>id: '+idinfo2[idinfo2.length-1].toString()+'<br />',
        '   <p>위도, 경도: '+polylinePath2[polylinePath2.length-1].toString()+'<br />',
        '   <p>배터리: '+battinfo2[battinfo2.length-1].toString()+'<br />',
        '   <p>시간: '+timeinfo2[timeinfo2.length-1].toString()+'<br />',
        '   </p>',
        '</div>'
    ].join('');

   var infowindow2 = new naver.maps.InfoWindow({
       content: contentString,
       maxWidth: 200,
       //borderColor: "#2db400",
       //borderWidth: 5,
       anchorSize: new naver.maps.Size(30, 30),
       anchorSkew: true,
       pixelOffset: new naver.maps.Point(20, -20)
   });
   
   naver.maps.Event.addListener(marker2, "click", function(e) {
       if (infowindow2.getMap()) {
           infowindow2.close();
       } else {
           infowindow2.open(map, marker2);
       }
   });
   
   
   const smenu = document.getElementsByClassName("submenu");
   console.log(smenu[0]);
   
   var polyarr = [polyline, polyline2];
   var markarr = [marker, marker2];
   
   func1 = function() { //id=1만 보기
	   if (polyarr[0].setMap(map)) {
		   	markarr[1].setMap(null);
   			polyarr[1].setMap(null);	
	   }
	   else {
		   markarr[1].setMap(map);
		   polyarr[1].setMap(map); }
   }
    
}

</script>
</body>
</html>