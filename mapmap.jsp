<%@ page language="java" contentType="text/html; charset=EUC-KR"
    pageEncoding="EUC-KR"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no">
    <title>����</title>
    <script type="text/javascript" src="http://code.jquery.com/jquery-latest.min.js"></script>
    <script type="text/javascript" src="https://openapi.map.naver.com/openapi/v3/maps.js?ncpClientId=z13sllck04"></script>
	
	<style>
		ul {list-style-type:none;
		padding-left:0px;
		float:right;
		}
		ul li {display:inline;
		/* li����� ���� 1px�� �׵θ� ����� */
		border-left: 1px solid #c0c0c0;
		/* �׵θ��� �޴� ���� ������, padding: �� ������ �Ʒ� ����; */
		padding: 0px 10px 0px 10px;
		/* �޴��� �׵θ� ���� ���� ������, margin: �� ������ �Ʒ� ����; */
		margin: 5px 0px 5px 0px;
		}
		ul li:first-child {
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
		<input type="date" id="dateFrom" name="from" >
  		~ <input type="date" id="dateTo" name="to">
		<button name="btnSearch" id="btnSearch" onclick = "javascript:datesearch()">�˻�</button>
		<li>
			<button onclick = "javascript:onehour()">1�ð�</button>
		</li>
		<li>
			<button onclick = "javascript:oneday()">1��</button>
		</li>
		<li>
			<button onclick = "javascript:oneweek()">������</button>
		</li>
		<li>
			<button onclick = "javascript:onemonth()">1����</button>
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

var onehourPolyPath2 = [];
var idinfohour2 = [];
var battinfohour2 = [];
var timeinfohour2 = [];

var onedayPolyPath = [];
var idinfoday = [];
var battinfoday = [];
var timeinfoday = [];

var onedayPolyPath2 = [];
var idinfoday2 = [];
var battinfoday2 = [];
var timeinfoday2 = [];

var oneweekPolyPath = [];
var idinfoweek = [];
var battinfoweek = [];
var timeinfoweek = [];

var oneweekPolyPath2 = [];
var idinfoweek2 = [];
var battinfoweek2 = [];
var timeinfoweek2 = [];

var onemonthPolyPath = [];
var idinfomonth = [];
var battinfomonth = [];
var timeinfomonth = [];

var onemonthPolyPath2 = [];
var idinfomonth2 = [];
var battinfomonth2 = [];
var timeinfomonth2 = [];

var datePolyPath = [];
var idinfodate = [];
var battinfodate = [];
var timeinfodate = [];

var datePolyPath2 = [];
var idinfodate2 = [];
var battinfodate2 = [];
var timeinfodate2 = [];

$(function(){
    $.ajax({
        url : "http://localhost/yhs/gpsPHP.php",
        dataType : "jsonp",
        jsonp : "callback"
    });
});



function callback(data) {
   let len=Object.values(data).length;

   var latArray = Object.entries(data.map(row=>row.lat)); //���� �迭
   var lngArray = Object.entries(data.map(row=>row.lng)); //�浵 �迭
   var idArray = Object.entries(data.map(row=>row.id)); //id �迭
   var battArray = Object.entries(data.map(row=>row.batt)); //���͸� �迭
   var timeArray = Object.entries(data.map(row=>row.time)); //�ð� �迭
   
   
   //id == 1
   
   for (let i=0; i<len; i++){ //�����浵 ������ ���̹� �迭�� �ֱ�
      let idStr = idArray[i].toString();
      if (idStr.split(',')[1] == "1") {
       polylinePath.push(new naver.maps.LatLng(parseFloat(latArray[i][1]), parseFloat(lngArray[i][1])));
       idinfo.push(idArray[i][1]);
       battinfo.push(battArray[i][1]);
       timeinfo.push(timeArray[i][1]);
      }
   }

   func1 = function() { //id=1
	   if (polylinePath.length == 0) {
			  alert("�����Ͱ� �����ϴ�.");
		  }
   
	   polyline = new naver.maps.Polyline({
	         map: map,
	            path: polylinePath,
	         strokeColor: '#FF0000', //�� �� ����
	         strokeOpacity: 0.8, //�� ���� 0 ~ 1
	         strokeWeight: 3   //�� �β�
	        });
	   
	   //������ ��ġ�� ��Ŀ ǥ��
	   marker = new naver.maps.Marker({
	        position: polylinePath[polylinePath.length-1], //��ũ ǥ���� ��ġ �迭�� ������ ��ġ
	        map: map
	    });
	   
	   //��Ŀ Ŭ�� �� ���� ǥ��
	   var contentString = [
	        '<div class="iw_inner">',
	        '   <h3>��� ����</h3>',
	        '   <p>id: '+idinfo[idinfo.length-1].toString()+'<br />',
	        '   <p>����, �浵: '+polylinePath[polylinePath.length-1].toString()+'<br />',
	        //'   <p>���͸�: '+battinfo[battinfo.length-1].toString()+"%"+'<br />',
	        '   <p>�ð�: '+timeinfo[timeinfo.length-1].toString()+'<br />',
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
   for (let i=0; i<len; i++){ //�����浵 ������ ���̹� �迭�� �ֱ�
      let idStr = idArray[i].toString();
      if (idStr.split(',')[1] == "2") {
          polylinePath2.push(new naver.maps.LatLng(parseFloat(latArray[i][1]), parseFloat(lngArray[i][1])));
          idinfo2.push(idArray[i][1]);
       //battinfo2.push(battArray[i][1]);
       timeinfo2.push(timeArray[i][1]);
      }
   }
   
   //��� �׸���
   func2 = function() {
	 if (polylinePath2.length == 0) {
			  alert("�����Ͱ� �����ϴ�.");
	}
	   
	 polyline2 = new naver.maps.Polyline({
         map: map,
         path: polylinePath2,
         strokeColor: '#00FF00', //�� �ʷ�
         strokeOpacity: 0.8, //�� ���� 0 ~ 1
         strokeWeight: 3   //�� �β�
        });
   
   //������ ��ġ�� ��Ŀ ǥ��
    marker2 = new naver.maps.Marker({
        position: polylinePath2[polylinePath2.length-1], //��ũ ǥ���� ��ġ �迭�� ������ ��ġ
        map: map
    });
   
   //��Ŀ Ŭ�� �� ���� ǥ��
   var contentString = [
        '<div class="iw_inner">',
        '   <h3>��� ����</h3>',
        '   <p>id: '+idinfo2[idinfo2.length-1].toString()+'<br />',
        '   <p>����, �浵: '+polylinePath2[polylinePath2.length-1].toString()+'<br />',
        //'   <p>���͸�: '+battinfo2[battinfo2.length-1].toString()+"%"+'<br />',
        '   <p>�ð�: '+timeinfo2[timeinfo2.length-1].toString()+'<br />',
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
   
  //�˻� ���
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
  
  //��¥
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
  
  
  onehour = function() { //1�ð�
	  newDate.setHours(newDate.getHours() - 1);
	  for (let i=0; i<len; i++) { 
		  if (timeArray[i][1] > dateFormat(newDate)) {
			let idStr = idArray[i].toString();
			if (idStr.split(',')[1] == "1") {
				onehourPolyPath.push(new naver.maps.LatLng(parseFloat(latArray[i][1]), parseFloat(lngArray[i][1])));
				idinfohour.push(idArray[i][1]);
				//battinfohour.push(battArray[i][1]);
				timeinfohour.push(timeArray[i][1]);
			   }
			if (idStr.split(',')[1] == "2") {
				onehourPolyPath2.push(new naver.maps.LatLng(parseFloat(latArray[i][1]), parseFloat(lngArray[i][1])));
				idinfohour2.push(idArray[i][1]);
				//battinfohour2.push(battArray[i][1]);
				timeinfohour2.push(timeArray[i][1]);
			   }
		  }
	  }
	  
	  if (onehourPolyPath.length == 0) {
		  alert("id�� 1�� �����Ͱ� �����ϴ�.");
	  }
	  
	  if (onehourPolyPath2.length == 0) {
		  alert("id�� 2�� �����Ͱ� �����ϴ�.");
	  }
	 
	  //id == 1
	  var onehourPoly = new naver.maps.Polyline({
	         map: map,
	         path: onehourPolyPath,
	         strokeColor: '#00FFFF',
	         strokeOpacity: 0.8, //�� ���� 0 ~ 1
	         strokeWeight: 3   //�� �β�
	        });
	   
	   //������ ��ġ�� ��Ŀ ǥ��
	   var hourmarker = new naver.maps.Marker({
	        position: onehourPolyPath[onehourPolyPath.length-1], //��ũ ǥ���� ��ġ �迭�� ������ ��ġ
	        map: map
	    });
	   
	   //��Ŀ Ŭ�� �� ���� ǥ��
	   var contentString = [
	        '<div class="iw_inner">',
	        '   <h3>��� ����</h3>',
	        '   <p>id: '+idinfohour[idinfohour.length-1].toString()+'<br />',
	        '   <p>����, �浵: '+onehourPolyPath[onehourPolyPath.length-1].toString()+'<br />',
	        //'   <p>���͸�: '+battinfohour[battinfohour.length-1].toString()+"%"+'<br />',
	        '   <p>�ð�: '+timeinfohour[timeinfohour.length-1].toString()+'<br />',
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
	   
	   //id == 2
	   var onehourPoly2 = new naver.maps.Polyline({
	         map: map,
	         path: onehourPolyPath2,
	         strokeColor: '#00FFFF',
	         strokeOpacity: 0.8, //�� ���� 0 ~ 1
	         strokeWeight: 3   //�� �β�
	        });
	   
	   //������ ��ġ�� ��Ŀ ǥ��
	   var hourmarker2 = new naver.maps.Marker({
	        position: onehourPolyPath2[onehourPolyPath2.length-1], //��ũ ǥ���� ��ġ �迭�� ������ ��ġ
	        map: map
	    });
	   
	   //��Ŀ Ŭ�� �� ���� ǥ��
	   var contentString = [
	        '<div class="iw_inner">',
	        '   <h3>��� ����</h3>',
	        '   <p>id: '+idinfohour2[idinfohour2.length-1].toString()+'<br />',
	        '   <p>����, �浵: '+onehourPolyPath2[onehourPolyPath2.length-1].toString()+'<br />',
	        //'   <p>���͸�: '+battinfohour2[battinfohour2.length-1].toString()+"%"+'<br />',
	        '   <p>�ð�: '+timeinfohour2[timeinfohour2.length-1].toString()+'<br />',
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
	   
	   naver.maps.Event.addListener(hourmarker2, "click", function(e) {
	       if (infowindow.getMap()) {
	           infowindow.close();
	       } else {
	           infowindow.open(map, hourmarker2);
	       }
	   });
  }
  
  oneday = function() { //1��
	  newDate2.setHours(newDate2.getHours() - 24);
	  for (let i=0; i<len; i++) {
		  if (timeArray[i][1] > dateFormat(newDate2)) {
			let idStr = idArray[i].toString();
			if (idStr.split(',')[1] == "1") {
				onedayPolyPath.push(new naver.maps.LatLng(parseFloat(latArray[i][1]), parseFloat(lngArray[i][1])));
				idinfoday.push(idArray[i][1]);
				//battinfoday.push(battArray[i][1]);
				timeinfoday.push(timeArray[i][1]);
			   }
			if (idStr.split(',')[1] == "2") {
				onedayPolyPath2.push(new naver.maps.LatLng(parseFloat(latArray[i][1]), parseFloat(lngArray[i][1])));
				idinfoday2.push(idArray[i][1]);
				//battinfoday2.push(battArray[i][1]);
				timeinfoday2.push(timeArray[i][1]);
			   }
		  }
	  }
	  
	  if (onedayPolyPath.length == 0) {
		  alert("id�� 1�� �����Ͱ� �����ϴ�.");
	  }
	  
	  if (onedayPolyPath2.length == 0) {
		  alert("id�� 2�� �����Ͱ� �����ϴ�.");
	  }
	 
	  //id == 1
	  var onedayPoly = new naver.maps.Polyline({
	         map: map,
	         path: onedayPolyPath,
	         strokeColor: '#FFFF00',
	         strokeOpacity: 0.8, //�� ���� 0 ~ 1
	         strokeWeight: 3   //�� �β�
	        });
	   
	   //������ ��ġ�� ��Ŀ ǥ��
	   var daymarker = new naver.maps.Marker({
	        position: onedayPolyPath[onedayPolyPath.length-1], //��ũ ǥ���� ��ġ �迭�� ������ ��ġ
	        map: map
	    });
	   
	   //��Ŀ Ŭ�� �� ���� ǥ��
	   var contentString = [
	        '<div class="iw_inner">',
	        '   <h3>��� ����</h3>',
	        '   <p>id: '+idinfoday[idinfoday.length-1].toString()+'<br />',
	        '   <p>����, �浵: '+onedayPolyPath[onedayPolyPath.length-1].toString()+'<br />',
	        //'   <p>���͸�: '+battinfoday[battinfoday.length-1].toString()+"%"+'<br />',
	        '   <p>�ð�: '+timeinfoday[timeinfoday.length-1].toString()+'<br />',
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
	   
	   //id == 2
	   var onedayPoly2 = new naver.maps.Polyline({
	         map: map,
	         path: onedayPolyPath2,
	         strokeColor: '#FFFF00',
	         strokeOpacity: 0.8, //�� ���� 0 ~ 1
	         strokeWeight: 3   //�� �β�
	        });
	   
	   //������ ��ġ�� ��Ŀ ǥ��
	   var daymarker2 = new naver.maps.Marker({
	        position: onedayPolyPath2[onedayPolyPath2.length-1], //��ũ ǥ���� ��ġ �迭�� ������ ��ġ
	        map: map
	    });
	   
	   //��Ŀ Ŭ�� �� ���� ǥ��
	   var contentString = [
	        '<div class="iw_inner">',
	        '   <h3>��� ����</h3>',
	        '   <p>id: '+idinfoday2[idinfoday2.length-1].toString()+'<br />',
	        '   <p>����, �浵: '+onedayPolyPath2[onedayPolyPath2.length-1].toString()+'<br />',
	        //'   <p>���͸�: '+battinfoday2[battinfoday2.length-1].toString()+"%"+'<br />',
	        '   <p>�ð�: '+timeinfoday2[timeinfoday2.length-1].toString()+'<br />',
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
	   
	   naver.maps.Event.addListener(daymarker2, "click", function(e) {
	       if (infowindow.getMap()) {
	           infowindow.close();
	       } else {
	           infowindow.open(map, daymarker2);
	       }
	   });
  }
  
  
  oneweek = function() { //1��
	  newDate3.setDate(newDate3.getDate() - 7);
	  for (let i=0; i<len; i++) {
		  if (timeArray[i][1].substr(0,10) >= dateFormat(newDate3)) {
			let idStr = idArray[i].toString();
			if (idStr.split(',')[1] == "1") {
				oneweekPolyPath.push(new naver.maps.LatLng(parseFloat(latArray[i][1]), parseFloat(lngArray[i][1])));
				idinfoweek.push(idArray[i][1]);
				//battinfoweek.push(battArray[i][1]);
				timeinfoweek.push(timeArray[i][1]);
			   }
			if (idStr.split(',')[1] == "2") {
				oneweekPolyPath2.push(new naver.maps.LatLng(parseFloat(latArray[i][1]), parseFloat(lngArray[i][1])));
				idinfoweek2.push(idArray[i][1]);
				//battinfoweek2.push(battArray[i][1]);
				timeinfoweek2.push(timeArray[i][1]);
			   }
		  }
	  }
	  
	  if (oneweekPolyPath.length == 0) {
		  alert("id�� 1�� �����Ͱ� �����ϴ�.");
	  }
	  
	  if (oneweekPolyPath2.length == 0) {
		  alert("id�� 2�� �����Ͱ� �����ϴ�.");
	  }
	 
	  //id == 1
	  var oneweekPoly = new naver.maps.Polyline({
	         map: map,
	         path: oneweekPolyPath,
	         strokeColor: '#0000FF',
	         strokeOpacity: 0.8, //�� ���� 0 ~ 1
	         strokeWeight: 3   //�� �β�
	        });
	   
	   //������ ��ġ�� ��Ŀ ǥ��
	   var weekmarker = new naver.maps.Marker({
	        position: oneweekPolyPath[oneweekPolyPath.length-1], //��ũ ǥ���� ��ġ �迭�� ������ ��ġ
	        map: map
	    });
	   
	   //��Ŀ Ŭ�� �� ���� ǥ��
	   var contentString = [
	        '<div class="iw_inner">',
	        '   <h3>��� ����</h3>',
	        '   <p>id: '+idinfoweek[idinfoweek.length-1].toString()+'<br />',
	        '   <p>����, �浵: '+oneweekPolyPath[oneweekPolyPath.length-1].toString()+'<br />',
	        //'   <p>���͸�: '+battinfoweek[battinfoweek.length-1].toString()+"%"+'<br />',
	        '   <p>�ð�: '+timeinfoweek[timeinfoweek.length-1].toString()+'<br />',
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
	   
	   //id == 2
	   var oneweekPoly2 = new naver.maps.Polyline({
	         map: map,
	         path: oneweekPolyPath2,
	         strokeColor: '#0000FF',
	         strokeOpacity: 0.8, //�� ���� 0 ~ 1
	         strokeWeight: 3   //�� �β�
	        });
	   
	   //������ ��ġ�� ��Ŀ ǥ��
	   var weekmarker2 = new naver.maps.Marker({
	        position: oneweekPolyPath2[oneweekPolyPath2.length-1], //��ũ ǥ���� ��ġ �迭�� ������ ��ġ
	        map: map
	    });
	   
	   //��Ŀ Ŭ�� �� ���� ǥ��
	   var contentString = [
	        '<div class="iw_inner">',
	        '   <h3>��� ����</h3>',
	        '   <p>id: '+idinfoweek2[idinfoweek2.length-1].toString()+'<br />',
	        '   <p>����, �浵: '+oneweekPolyPath2[oneweekPolyPath2.length-1].toString()+'<br />',
	        //'   <p>���͸�: '+battinfoweek2[battinfoweek2.length-1].toString()+"%"+'<br />',
	        '   <p>�ð�: '+timeinfoweek2[timeinfoweek2.length-1].toString()+'<br />',
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
	   
	   naver.maps.Event.addListener(weekmarker2, "click", function(e) {
	       if (infowindow.getMap()) {
	           infowindow.close();
	       } else {
	           infowindow.open(map, weekmarker2);
	       }
	   });
  }
  
  
  onemonth = function() { //1����
	  newDate4.setMonth(newDate4.getMonth() - 1);
	  for (let i=0; i<len; i++) {
		  if (timeArray[i][1].substr(0,10) >= dateFormat(newDate4)) {
			let idStr = idArray[i].toString();
			if (idStr.split(',')[1] == "1") {
				onemonthPolyPath.push(new naver.maps.LatLng(parseFloat(latArray[i][1]), parseFloat(lngArray[i][1])));
				idinfomonth.push(idArray[i][1]);
				//battinfomonth.push(battArray[i][1]);
				timeinfomonth.push(timeArray[i][1]);
			   }
			if (idStr.split(',')[1] == "2") {
				onemonthPolyPath2.push(new naver.maps.LatLng(parseFloat(latArray[i][1]), parseFloat(lngArray[i][1])));
				idinfomonth2.push(idArray[i][1]);
				//battinfomonth2.push(battArray[i][1]);
				timeinfomonth2.push(timeArray[i][1]);
			   }
		  }
	  }
	  
	  if (onemonthPolyPath.length == 0) {
		  alert("id�� 1�� �����Ͱ� �����ϴ�.");
	  }
	  
	  if (onemonthPolyPath2.length == 0) {
		  alert("id�� 2�� �����Ͱ� �����ϴ�.");
	  }
	 
	  //id == 1
	  var onemonthPoly = new naver.maps.Polyline({
	         map: map,
	         path: onemonthPolyPath,
	         strokeColor: '#FF00FF',
	         strokeOpacity: 0.8, //�� ���� 0 ~ 1
	         strokeWeight: 3   //�� �β�
	        });
	   
	   //������ ��ġ�� ��Ŀ ǥ��
	   var monthmarker = new naver.maps.Marker({
	        position: onemonthPolyPath[onemonthPolyPath.length-1], //��ũ ǥ���� ��ġ �迭�� ������ ��ġ
	        map: map
	    });
	   
	   //��Ŀ Ŭ�� �� ���� ǥ��
	   var contentString = [
	        '<div class="iw_inner">',
	        '   <h3>��� ����</h3>',
	        '   <p>id: '+idinfomonth[idinfomonth.length-1].toString()+'<br />',
	        '   <p>����, �浵: '+onemonthPolyPath[onemonthPolyPath.length-1].toString()+'<br />',
	        //'   <p>���͸�: '+battinfomonth[battinfomonth.length-1].toString()+"%"+'<br />',
	        '   <p>�ð�: '+timeinfomonth[timeinfomonth.length-1].toString()+'<br />',
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
	   
	   //id == 2
	   var onemonthPoly2 = new naver.maps.Polyline({
	         map: map,
	         path: onemonthPolyPath2,
	         strokeColor: '#FF00FF',
	         strokeOpacity: 0.8, //�� ���� 0 ~ 1
	         strokeWeight: 3   //�� �β�
	        });
	   
	   //������ ��ġ�� ��Ŀ ǥ��
	   var monthmarker2 = new naver.maps.Marker({
	        position: onemonthPolyPath2[onemonthPolyPath2.length-1], //��ũ ǥ���� ��ġ �迭�� ������ ��ġ
	        map: map
	    });
	   
	   //��Ŀ Ŭ�� �� ���� ǥ��
	   var contentString = [
	        '<div class="iw_inner">',
	        '   <h3>��� ����</h3>',
	        '   <p>id: '+idinfomonth2[idinfomonth2.length-1].toString()+'<br />',
	        '   <p>����, �浵: '+onemonthPolyPath2[onemonthPolyPath2.length-1].toString()+'<br />',
	        //'   <p>���͸�: '+battinfomonth2[battinfomonth2.length-1].toString()+"%"+'<br />',
	        '   <p>�ð�: '+timeinfomonth2[timeinfomonth2.length-1].toString()+'<br />',
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
	   
	   naver.maps.Event.addListener(monthmarker2, "click", function(e) {
	       if (infowindow.getMap()) {
	           infowindow.close();
	       } else {
	           infowindow.open(map, monthmarker2);
	       }
	   });
  }
  
  //��¥ ���� ��ȸ
  datesearch = function() {
	  var dateFrom = document.getElementById('dateFrom');	//������
	  var dateTo = document.getElementById('dateTo');	//������
	  var today = new Date();				//���� ��¥

	  dateFrom = new Date(dateFrom.value);
	  var fromYear = dateFrom.getFullYear();
	  var fromMonth = dateFrom.getMonth() + 1;
	  var fromDay = dateFrom.getDate();

	  //��¥ ������ ���� �ʾ��� �� NaN�� �߻��Ͽ� 0���� ó��
	  if (isNaN(fromYear) || isNaN(fromMonth) || isNaN(fromDay)){
	    fromYear  = 0;
	    fromMonth = 0;
	    fromDay   = 0;
	  }

	  dateFrom = fromYear +'-'+ ("0"+fromMonth).slice(-2) + '-' + ("0"+fromDay).slice(-2);

	  dateTo = new Date(dateTo.value);
	  var toYear  = dateTo.getFullYear();
	  var toMonth = dateTo.getMonth() + 1;
	  var toDay   = dateTo.getDate();

	  //��¥ ������ ���� �ʾ��� �� NaN�� �߻��Ͽ� 0���� ó��
	  if (isNaN(toYear) || isNaN(toMonth) || isNaN(toDay)){
	  	toYear  = 0;
	  	toMonth = 0;
	  	toDay   = 0;
	  }

	  dateTo = toYear +'-'+ ("0"+toMonth).slice(-2) + '-' + ("0"+toDay).slice(-2);

	  if((dateTo < dateFrom) || (dateTo == "0-00-00") || (dateFrom == "0-00-00")){
		 alert("�ش� �Ⱓ�� ��ȸ�� �Ұ����մϴ�.");
	  }
	  
	  //��� �׸���
	  for (let i=0; i<len; i++) {
		  if (timeArray[i][1].substr(0,10) >= dateFrom && timeArray[i][1].substr(0,10) <= dateTo) {
			let idStr = idArray[i].toString();
			if (idStr.split(',')[1] == "1") {
				datePolyPath.push(new naver.maps.LatLng(parseFloat(latArray[i][1]), parseFloat(lngArray[i][1])));
				idinfodate.push(idArray[i][1]);
				//battinfodate.push(battArray[i][1]);
				timeinfodate.push(timeArray[i][1]);
			   }
			else if (idStr.split(',')[1] == "2") {
				datePolyPath2.push(new naver.maps.LatLng(parseFloat(latArray[i][1]), parseFloat(lngArray[i][1])));
				idinfodate2.push(idArray[i][1]);
				//battinfodate2.push(battArray[i][1]);
				timeinfodate2.push(timeArray[i][1]);
			   }
		  }
	  }
	  
	  /*if (datePolyPath.length == 0) {
		  alert("id�� 1�� �����Ͱ� �����ϴ�.");
	  }
	  
	  if (datePolyPath2.length == 0) {
		  alert("id�� 2�� �����Ͱ� �����ϴ�.");
	  }*/
	  
	 //id == 1
	  var datePoly = new naver.maps.Polyline({
	         map: map,
	         path: datePolyPath,
	         strokeColor: '#FF00FF',
	         strokeOpacity: 0.8, //�� ���� 0 ~ 1
	         strokeWeight: 3   //�� �β�
	        });
	   
	   //������ ��ġ�� ��Ŀ ǥ��
	   var datemarker = new naver.maps.Marker({
	        position: datePolyPath[datePolyPath.length-1], //��ũ ǥ���� ��ġ �迭�� ������ ��ġ
	        map: map
	    });
	   
	   //��Ŀ Ŭ�� �� ���� ǥ��
	   var contentString = [
	        '<div class="iw_inner">',
	        '   <h3>��� ����</h3>',
	        '   <p>id: '+idinfodate[idinfodate.length-1].toString()+'<br />',
	        '   <p>����, �浵: '+datePolyPath[datePolyPath.length-1].toString()+'<br />',
	        //'   <p>���͸�: '+battinfodate[battinfodate.length-1].toString()+"%"+'<br />',
	        '   <p>�ð�: '+timeinfodate[timeinfodate.length-1].toString()+'<br />',
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
	   
	   naver.maps.Event.addListener(datemarker, "click", function(e) {
	       if (infowindow.getMap()) {
	           infowindow.close();
	       } else {
	           infowindow.open(map, datemarker);
	       }
	   });
	   
	   //id == 2
	   var datePoly2 = new naver.maps.Polyline({
	         map: map,
	         path: datePolyPath2,
	         strokeColor: '#FF00FF',
	         strokeOpacity: 0.8, //�� ���� 0 ~ 1
	         strokeWeight: 3   //�� �β�
	        });
	   
	   //������ ��ġ�� ��Ŀ ǥ��
	   var datemarker2 = new naver.maps.Marker({
	        position: datePolyPath2[datePolyPath2.length-1], //��ũ ǥ���� ��ġ �迭�� ������ ��ġ
	        map: map
	    });
	   
	   //��Ŀ Ŭ�� �� ���� ǥ��
	   var contentString = [
	        '<div class="iw_inner">',
	        '   <h3>��� ����</h3>',
	        '   <p>id: '+idinfodate2[idinfodate2.length-1].toString()+'<br />',
	        '   <p>����, �浵: '+datePolyPath2[datePolyPath2.length-1].toString()+'<br />',
	        //'   <p>���͸�: '+battinfodate2[battinfodate2.length-1].toString()+"%"+'<br />',
	        '   <p>�ð�: '+timeinfodate2[timeinfodate2.length-1].toString()+'<br />',
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
	   
	   naver.maps.Event.addListener(datemarker2, "click", function(e) {
	       if (infowindow.getMap()) {
	           infowindow.close();
	       } else {
	           infowindow.open(map, datemarker2);
	       }
	   });

  }
    
}

</script>
<input id=txt type="text" class='input_text' name="search" placeholder="id�� �Է��ϼ���" onkeydown="enterKey()"/>
<input type="button" class='btn' value="�˻�" onclick="enterKey()"/>
</body>
</html>