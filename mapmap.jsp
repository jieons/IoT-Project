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
		
		.input_text {
			position: absolute;
  			top: 25px;
		 }
		 
		 .btn {
		 	position: absolute;
  			top: 25px;
  			left: 180px;
		 }
</style>

</head>
<body>
	<div>
	<ul class="menu">
		<li>
			<button onclick = "javascript:onehour()">1시간</button>
		</li>
		<li>
			<button onclick = "javascript:oneday()">1일</button>
		</li>
		<li>
			<button onclick = "javascript:oneweek()">일주일</button>
		</li>
		<li>
			<button onclick = "javascript:onemonth()">1개월</button>
		</li>
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

var polyarr = [];
var markarr = [];

var polyline;
var marker;
var polyline2;
var marker2;

var inputValue;

var onehourPolyPath = [];
var idinfohour = [];
var battinfohour = [];
var timeinfohour = [];

var onedayPolyPath = [];
var idinfoday = [];
var battinfoday = [];
var timeinfoday = [];

var oneweekPolyPath = [];
var idinfoweek = [];
var battinfoweek = [];
var timeinfoweek = [];

var onemonthPolyPath = [];
var idinfomonth = [];
var battinfomonth = [];
var timeinfomonth = [];

//let i=0;
$(function(){
    $.ajax({
        url : "http://localhost/yhs/gpsPHP.php",
        dataType : "jsonp",
        jsonp : "callback"
    });
});



function callback(data) {
   let len=Object.values(data).length;

   var latArray = Object.entries(data.map(row=>row.lat)); //위도 배열
   var lngArray = Object.entries(data.map(row=>row.lng)); //경도 배열
   var idArray = Object.entries(data.map(row=>row.id)); //id 배열
   var battArray = Object.entries(data.map(row=>row.batt)); //배터리 배열
   var timeArray = Object.entries(data.map(row=>row.time)); //시간 배열
   
   
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

   func1 = function() { //id=1
	   polyline = new naver.maps.Polyline({
	         map: map,
	            path: polylinePath,
	         strokeColor: '#FF0000', //선 색 빨강
	         strokeOpacity: 0.8, //선 투명도 0 ~ 1
	         strokeWeight: 3   //선 두께
	        });
	   
	   //마지막 위치에 마커 표시
	   marker = new naver.maps.Marker({
	        position: polylinePath[polylinePath.length-1], //마크 표시할 위치 배열의 마지막 위치
	        map: map
	    });
	   
	   //마커 클릭 시 정보 표시
	   var contentString = [
	        '<div class="iw_inner">',
	        '   <h3>기기 정보</h3>',
	        '   <p>id: '+idinfo[idinfo.length-1].toString()+'<br />',
	        '   <p>위도, 경도: '+polylinePath[polylinePath.length-1].toString()+'<br />',
	        '   <p>배터리: '+battinfo[battinfo.length-1].toString()+"%"+'<br />',
	        '   <p>시간: '+timeinfo[timeinfo.length-1].toString()+'<br />',
	        '   </p>',
	        '</div>'
	    ].join('');

	   var infowindow = new naver.maps.InfoWindow({
	       content: contentString,
	       maxWidth: 200,
	       borderColor: "#B4B4B4",
	       borderWidth: 5,
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
   }
   

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
   func2 = function() {
	 polyline2 = new naver.maps.Polyline({
         map: map,
         path: polylinePath2,
         strokeColor: '#00FF00', //선 초록
         strokeOpacity: 0.8, //선 투명도 0 ~ 1
         strokeWeight: 3   //선 두께
        });
   
   //마지막 위치에 마커 표시
    marker2 = new naver.maps.Marker({
        position: polylinePath2[polylinePath2.length-1], //마크 표시할 위치 배열의 마지막 위치
        map: map
    });
   
   //마커 클릭 시 정보 표시
   var contentString = [
        '<div class="iw_inner">',
        '   <h3>기기 정보</h3>',
        '   <p>id: '+idinfo2[idinfo2.length-1].toString()+'<br />',
        '   <p>위도, 경도: '+polylinePath2[polylinePath2.length-1].toString()+'<br />',
        '   <p>배터리: '+battinfo2[battinfo2.length-1].toString()+"%"+'<br />',
        '   <p>시간: '+timeinfo2[timeinfo2.length-1].toString()+'<br />',
        '   </p>',
        '</div>'
    ].join('');

   var infowindow2 = new naver.maps.InfoWindow({
       content: contentString,
       maxWidth: 200,
       borderColor: "#B4B4B4",
       borderWidth: 5,
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
  }
   
   funcD1 = function() {
		marker.setMap(null);
		polyline.setMap(null);
   }
   
   funcD2 = function() {
		marker2.setMap(null);
		polyline2.setMap(null);
   }
   
   funcAll = function() {
	   func1();
	   func2();
   }
   
   funcDAll = function() {
	   funcD1();
	   funcD2();
   }
   
  //검색 기능
  enterKey = function() {
      if (event.keyCode == 13) {
    	  inputValue = document.getElementById("txt").value;
    	  if (inputValue == '1') {
    		  func1();
    	  }
    	  if (inputValue == '2') {
    		  func2();
    	  }
      }
      if (event.keyCode == 8) {
    	  funcDAll();
      }
	}
  
  //날짜
  const date = new Date();
  const year = date.getFullYear();
  const month = date.getMonth() + 1;
  const day = date.getDate();
  var newDate = new Date();
  var newDate2 = new Date();
  var newDate3 = new Date();
  var newDate4 = new Date();
  
  const hours = date.getUTCHours() + 9;
  const minutes = date.getUTCMinutes();
  const seconds = date.getUTCSeconds();
  
  
  dateFormat = function(today) {
	  let year = today.getFullYear();
	  let month = today.getMonth() + 1;
	  let day = today.getDate();
	  let hours = date.getHours();
	  let minutes = date.getUTCMinutes();
	  let seconds = date.getUTCSeconds();
	  
	  month = ("0"+month).slice(-2);
	  day = ("0"+day).slice(-2);
	  hours = ("0"+hours).slice(-2);
	  minutes = ("0"+minutes).slice(-2);
	  seconds = ("0"+seconds).slice(-2);
	  
	  return year + "-" + month + "-" + day + " " + hours + ":" + minutes + ":" + seconds;
  }
  
  
  onehour = function() { //1시간
	  newDate.setHours(newDate.getHours() - 1);
	  for (let i=0; i<len; i++) { 
		  if (timeArray[i][1] > dateFormat(newDate)) {
			let idStr = idArray[i].toString();
			if (idStr.split(',')[1] == "1") {
				onehourPolyPath.push(new naver.maps.LatLng(parseFloat(latArray[i][1]), parseFloat(lngArray[i][1])));
				idinfohour.push(idArray[i][1]);
				battinfohour.push(battArray[i][1]);
				timeinfohour.push(timeArray[i][1]);
			   }
		  }
	  }
	  
	  if (onehourPolyPath.length == 0) {
		  alert("데이터가 없습니다.");
	  }
	 
	  var onehourPoly = new naver.maps.Polyline({
	         map: map,
	         path: onehourPolyPath,
	         strokeColor: '#00FFFF',
	         strokeOpacity: 0.8, //선 투명도 0 ~ 1
	         strokeWeight: 3   //선 두께
	        });
	   
	   //마지막 위치에 마커 표시
	   var hourmarker = new naver.maps.Marker({
	        position: onehourPolyPath[onehourPolyPath.length-1], //마크 표시할 위치 배열의 마지막 위치
	        map: map
	    });
	   
	   //마커 클릭 시 정보 표시
	   var contentString = [
	        '<div class="iw_inner">',
	        '   <h3>기기 정보</h3>',
	        '   <p>id: '+idinfohour[idinfohour.length-1].toString()+'<br />',
	        '   <p>위도, 경도: '+onehourPolyPath[onehourPolyPath.length-1].toString()+'<br />',
	        '   <p>배터리: '+battinfohour[battinfohour.length-1].toString()+"%"+'<br />',
	        '   <p>시간: '+timeinfohour[timeinfohour.length-1].toString()+'<br />',
	        '   </p>',
	        '</div>'
	    ].join('');

	   var infowindow = new naver.maps.InfoWindow({
	       content: contentString,
	       maxWidth: 200,
	       borderColor: "#B4B4B4",
	       borderWidth: 5,
	       anchorSize: new naver.maps.Size(30, 30),
	       anchorSkew: true,
	       pixelOffset: new naver.maps.Point(20, -20)
	   });
	   
	   naver.maps.Event.addListener(hourmarker, "click", function(e) {
	       if (infowindow.getMap()) {
	           infowindow.close();
	       } else {
	           infowindow.open(map, hourmarker);
	       }
	   });
  }
  
  oneday = function() { //1일
	  newDate2.setHours(newDate2.getHours() - 24);
	  for (let i=0; i<len; i++) {
		  if (timeArray[i][1] > dateFormat(newDate2)) {
			let idStr = idArray[i].toString();
			if (idStr.split(',')[1] == "1") {
				onedayPolyPath.push(new naver.maps.LatLng(parseFloat(latArray[i][1]), parseFloat(lngArray[i][1])));
				idinfoday.push(idArray[i][1]);
				battinfoday.push(battArray[i][1]);
				timeinfoday.push(timeArray[i][1]);
			   }
		  }
	  }
	  
	  if (onedayPolyPath.length == 0) {
		  alert("데이터가 없습니다.");
	  }
	 
	  var onedayPoly = new naver.maps.Polyline({
	         map: map,
	         path: onedayPolyPath,
	         strokeColor: '#FFFF00',
	         strokeOpacity: 0.8, //선 투명도 0 ~ 1
	         strokeWeight: 3   //선 두께
	        });
	   
	   //마지막 위치에 마커 표시
	   var daymarker = new naver.maps.Marker({
	        position: onedayPolyPath[onedayPolyPath.length-1], //마크 표시할 위치 배열의 마지막 위치
	        map: map
	    });
	   
	   //마커 클릭 시 정보 표시
	   var contentString = [
	        '<div class="iw_inner">',
	        '   <h3>기기 정보</h3>',
	        '   <p>id: '+idinfoday[idinfoday.length-1].toString()+'<br />',
	        '   <p>위도, 경도: '+onedayPolyPath[onedayPolyPath.length-1].toString()+'<br />',
	        '   <p>배터리: '+battinfoday[battinfoday.length-1].toString()+"%"+'<br />',
	        '   <p>시간: '+timeinfoday[timeinfoday.length-1].toString()+'<br />',
	        '   </p>',
	        '</div>'
	    ].join('');

	   var infowindow = new naver.maps.InfoWindow({
	       content: contentString,
	       maxWidth: 200,
	       borderColor: "#B4B4B4",
	       borderWidth: 5,
	       anchorSize: new naver.maps.Size(30, 30),
	       anchorSkew: true,
	       pixelOffset: new naver.maps.Point(20, -20)
	   });
	   
	   naver.maps.Event.addListener(daymarker, "click", function(e) {
	       if (infowindow.getMap()) {
	           infowindow.close();
	       } else {
	           infowindow.open(map, daymarker);
	       }
	   });
  }
  
  
  oneweek = function() { //1주
	  newDate3.setDate(newDate3.getDate() - 7);
	  for (let i=0; i<len; i++) {
		  if (timeArray[i][1].substr(0,10) >= dateFormat(newDate3)) {
			let idStr = idArray[i].toString();
			if (idStr.split(',')[1] == "1") {
				oneweekPolyPath.push(new naver.maps.LatLng(parseFloat(latArray[i][1]), parseFloat(lngArray[i][1])));
				idinfoweek.push(idArray[i][1]);
				battinfoweek.push(battArray[i][1]);
				timeinfoweek.push(timeArray[i][1]);
			   }
		  }
	  }
	  
	  if (oneweekPolyPath.length == 0) {
		  alert("데이터가 없습니다.");
	  }
	 
	  var oneweekPoly = new naver.maps.Polyline({
	         map: map,
	         path: oneweekPolyPath,
	         strokeColor: '#0000FF',
	         strokeOpacity: 0.8, //선 투명도 0 ~ 1
	         strokeWeight: 3   //선 두께
	        });
	   
	   //마지막 위치에 마커 표시
	   var weekmarker = new naver.maps.Marker({
	        position: oneweekPolyPath[oneweekPolyPath.length-1], //마크 표시할 위치 배열의 마지막 위치
	        map: map
	    });
	   
	   //마커 클릭 시 정보 표시
	   var contentString = [
	        '<div class="iw_inner">',
	        '   <h3>기기 정보</h3>',
	        '   <p>id: '+idinfoweek[idinfoweek.length-1].toString()+'<br />',
	        '   <p>위도, 경도: '+oneweekPolyPath[oneweekPolyPath.length-1].toString()+'<br />',
	        '   <p>배터리: '+battinfoweek[battinfoweek.length-1].toString()+"%"+'<br />',
	        '   <p>시간: '+timeinfoweek[timeinfoweek.length-1].toString()+'<br />',
	        '   </p>',
	        '</div>'
	    ].join('');

	   var infowindow = new naver.maps.InfoWindow({
	       content: contentString,
	       maxWidth: 200,
	       borderColor: "#B4B4B4",
	       borderWidth: 5,
	       anchorSize: new naver.maps.Size(30, 30),
	       anchorSkew: true,
	       pixelOffset: new naver.maps.Point(20, -20)
	   });
	   
	   naver.maps.Event.addListener(weekmarker, "click", function(e) {
	       if (infowindow.getMap()) {
	           infowindow.close();
	       } else {
	           infowindow.open(map, weekmarker);
	       }
	   });
  }
  
  
  onemonth = function() { //1개월
	  newDate4.setMonth(newDate4.getMonth() - 1);
	  for (let i=0; i<len; i++) {
		  if (timeArray[i][1].substr(0,10) >= dateFormat(newDate4)) {
			let idStr = idArray[i].toString();
			if (idStr.split(',')[1] == "1") {
				onemonthPolyPath.push(new naver.maps.LatLng(parseFloat(latArray[i][1]), parseFloat(lngArray[i][1])));
				idinfomonth.push(idArray[i][1]);
				battinfomonth.push(battArray[i][1]);
				timeinfomonth.push(timeArray[i][1]);
			   }
		  }
	  }
	  
	  if (onemonthPolyPath.length == 0) {
		  alert("데이터가 없습니다.");
	  }
	 
	  var onemonthPoly = new naver.maps.Polyline({
	         map: map,
	         path: onemonthPolyPath,
	         strokeColor: '#FF00FF',
	         strokeOpacity: 0.8, //선 투명도 0 ~ 1
	         strokeWeight: 3   //선 두께
	        });
	   
	   //마지막 위치에 마커 표시
	   var monthmarker = new naver.maps.Marker({
	        position: onemonthPolyPath[onemonthPolyPath.length-1], //마크 표시할 위치 배열의 마지막 위치
	        map: map
	    });
	   
	   //마커 클릭 시 정보 표시
	   var contentString = [
	        '<div class="iw_inner">',
	        '   <h3>기기 정보</h3>',
	        '   <p>id: '+idinfomonth[idinfomonth.length-1].toString()+'<br />',
	        '   <p>위도, 경도: '+onemonthPolyPath[onemonthPolyPath.length-1].toString()+'<br />',
	        '   <p>배터리: '+battinfomonth[battinfomonth.length-1].toString()+"%"+'<br />',
	        '   <p>시간: '+timeinfomonth[timeinfomonth.length-1].toString()+'<br />',
	        '   </p>',
	        '</div>'
	    ].join('');

	   var infowindow = new naver.maps.InfoWindow({
	       content: contentString,
	       maxWidth: 200,
	       borderColor: "#B4B4B4",
	       borderWidth: 5,
	       anchorSize: new naver.maps.Size(30, 30),
	       anchorSkew: true,
	       pixelOffset: new naver.maps.Point(20, -20)
	   });
	   
	   naver.maps.Event.addListener(monthmarker, "click", function(e) {
	       if (infowindow.getMap()) {
	           infowindow.close();
	       } else {
	           infowindow.open(map, monthmarker);
	       }
	   });
  }
    
}

</script>
<input id=txt type="text" class='input_text' name="search" placeholder="id를 입력하세요" onkeydown="enterKey()"/>
<input type="button" class='btn' value="검색" onclick="enterKey()"/>
</body>
</html>