<?php
//include "../lib/session.php";             
//include "../lib/connect_db.php"; 

$host = "localhost";      //호스트 이름
$user = "root";            //사용자 계정
$passwd = "wldjs1216";   //비밀번호
$connect = mysqli_connect($host, $user, $passwd) or die("mysql서버 접속 에러");
$db = mysqli_select_db($connect, 'gps_test');
mysqli_select_db($connect, 'gps_test') or die("DB 접속 에러");      //my_db 선택
   
$sql = "select * from info";
$result = mysqli_query($connect, $sql);
$count = 0;
$num_rows = mysqli_num_rows($result);
$members = array();
while($row = mysqli_fetch_array($result)){
    $member = array("id" => $row[0], "lng" => $row[1], "lat" => $row[2], "time" => $row[3], "batt" => $row[4]);  
    array_push($members, $member);
}
$jsondata['result'] = $members;


echo "callback(" . json_encode($jsondata['result']) . ")";

?>