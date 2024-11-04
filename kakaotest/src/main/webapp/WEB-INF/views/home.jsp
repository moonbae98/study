<%@ page contentType="text/html; charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title>Gas Station Map</title>
    <meta charset="UTF-8">
    <script src="https://cdnjs.cloudflare.com/ajax/libs/proj4js/2.6.2/proj4.js"></script>
    <script type="text/javascript" src="https://dapi.kakao.com/v2/maps/sdk.js?appkey=9dc9962fd8d9c313d5ca5a57212228ab&libraries=services"></script>
    <style>
        #map {
            width: 100%;
            height: 500px;
        }
    </style>
</head>
<body>
<h1>Gas Stations in Seoul</h1>

<div id="map"></div>

<script>
    // Proj4js 좌표계 정의 (EPSG:5178 -> WGS84)
    proj4.defs("EPSG:5178", "+proj=tmerc +lat_0=38 +lon_0=128 +k=0.9999 +x_0=400000 +y_0=600000 +ellps=GRS80 +units=m +no_defs");
    proj4.defs("EPSG:4326", "+proj=longlat +datum=WGS84 +no_defs");

    // 변환할 KATEC 좌표 예시
    var katecX = 311314.10000;
    var katecY = 544500.60000;

    // EPSG:5178 (KATEC) 좌표를 EPSG:4326 (WGS84) 좌표로 변환
    var [wgs84Lng, wgs84Lat] = proj4("EPSG:5178", "EPSG:4326", [katecX, katecY]);

    console.log("변환된 WGS84 좌표:", wgs84Lat, wgs84Lng); // 변환 결과 확인

    // 카카오맵 지도 설정
    var mapContainer = document.getElementById('map');
    var mapOption = {
        center: new kakao.maps.LatLng(wgs84Lat, wgs84Lng), // 변환된 WGS84 좌표로 설정
        level: 7
    };
    var map = new kakao.maps.Map(mapContainer, mapOption);

    // 장소 검색 서비스 객체 생성
    var ps = new kakao.maps.services.Places();

    // 주유소 카테고리 코드 "OL7"을 사용하여 주유소 검색
    ps.categorySearch('OL7', function(data, status, pagination) {
        if (status === kakao.maps.services.Status.OK) {
            // 주유소 검색 성공 시, 결과를 지도에 표시
            for (var i = 0; i < data.length; i++) {
                displayMarker(data[i]);
            }
        } else {
            console.error("주유소 검색 실패:", status);
        }
    }, {
        location: new kakao.maps.LatLng(wgs84Lat, wgs84Lng),
        radius: 5000 // 반경 5km 내에서 검색
    });

    // 주유소 위치에 마커를 표시하는 함수
    function displayMarker(place) {
        var markerPosition = new kakao.maps.LatLng(place.y, place.x);
        console.log(place);
        var marker = new kakao.maps.Marker({
            map: map,
            position: markerPosition
        });

        // 마커에 클릭 이벤트 등록 (인포윈도우 표시)
        kakao.maps.event.addListener(marker, 'click', function() {
            var infowindow = new kakao.maps.InfoWindow({
                content: '<div style="padding:10px;">' + place.place_name + '</div>'
            });
            infowindow.open(map, marker);
        });
    }
</script>

</body>
</html>
