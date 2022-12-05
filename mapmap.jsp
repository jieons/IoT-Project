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
		/* li�� ù��° ��� �������� �׵θ� ���ֱ� */
		border-left: none;
		}
		
		.menu {
		  position : relative;
		  display : inline-block;
		}
		
		.submenu {
		  display : none;
		  position : absolute;
		  z-index : 1; /*�ٸ� ��ҵ麸�� �տ� ��ġ*/
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
			<a href="#">id���� ����</a>
			<ul class="submenu">
	          <li><a href="#" onclick="func1()">id = 1</a></li>
	          <li><a href="javascript:func2()">id = 2</a></li>
        	</ul>
		</li>
		<li>�޴� 2</li>
		<li>�޴� 3</li>
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

   var latArray = Object.entries(data.map(row=>row.lat)); //���� �迭
   var lngArray = Object.entries(data.map(row=>row.lng)); //�浵 �迭
   var idArray = Object.entries(data.map(row=>row.id)); //id �迭
   var battArray = Object.entries(data.map(row=>row.batt)); //���͸� �迭
   var timeArray = Object.entries(data.map(row=>row.time)); //�ð� �迭
   
   console.log(idArray);
   
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
   
   //��� �׸���
   var polyline = new naver.maps.Polyline({
         map: map,
            path: polylinePath,
         strokeColor: '#FF0000', //�� �� ����
         strokeOpacity: 0.8, //�� ���� 0 ~ 1
         strokeWeight: 3   //�� �β�
        });
   
   //������ ��ġ�� ��Ŀ ǥ��
   var marker = new naver.maps.Marker({
        position: polylinePath[polylinePath.length-1], //��ũ ǥ���� ��ġ �迭�� ������ ��ġ
        map: map
    });
   
   //��Ŀ Ŭ�� �� ���� ǥ��
   var contentString = [
        '<div class="iw_inner">',
        '   <h3>��� ����</h3>',
        '   <p>id: '+idinfo[idinfo.length-1].toString()+'<br />',
        '   <p>����, �浵: '+polylinePath[polylinePath.length-1].toString()+'<br />',
        '   <p>���͸�: '+battinfo[battinfo.length-1].toString()+'<br />',
        '   <p>�ð�: '+timeinfo[timeinfo.length-1].toString()+'<br />',
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
   
   

   /*naver.maps.Event.addListener(id1, "click", function(e) { //id=1�� ����
	   if (polyline2.getMap(map))
    		polyline.getMap(null);
	   else
		   polyline2.getMap(map);
   });*/
   
   
   
   //id == 2
   for (let i=0; i<len; i++){ //�����浵 ������ ���̹� �迭�� �ֱ�
      let idStr = idArray[i].toString();
      if (idStr.split(',')[1] == "2") {
          polylinePath2.push(new naver.maps.LatLng(parseFloat(latArray[i][1]), parseFloat(lngArray[i][1])));
          idinfo2.push(idArray[i][1]);
       battinfo2.push(battArray[i][1]);
       timeinfo2.push(timeArray[i][1]);
      }
   }
   
   //��� �׸���
   var polyline2 = new naver.maps.Polyline({
         map: map,
            path: polylinePath2,
         strokeColor: '#00FF00', //�� �ʷ�
         strokeOpacity: 0.8, //�� ���� 0 ~ 1
         strokeWeight: 3   //�� �β�
        });
   
   //������ ��ġ�� ��Ŀ ǥ��
   var marker2 = new naver.maps.Marker({
        position: polylinePath2[polylinePath2.length-1], //��ũ ǥ���� ��ġ �迭�� ������ ��ġ
        map: map
    });
   
   //��Ŀ Ŭ�� �� ���� ǥ��
   var contentString = [
        '<div class="iw_inner">',
        '   <h3>��� ����</h3>',
        '   <p>id: '+idinfo2[idinfo2.length-1].toString()+'<br />',
        '   <p>����, �浵: '+polylinePath2[polylinePath2.length-1].toString()+'<br />',
        '   <p>���͸�: '+battinfo2[battinfo2.length-1].toString()+'<br />',
        '   <p>�ð�: '+timeinfo2[timeinfo2.length-1].toString()+'<br />',
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
   
   func1 = function() { //id=1�� ����
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