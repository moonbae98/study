package com.human.kakao;

import java.text.DateFormat;
import java.util.Date;
import java.util.Locale;

import org.locationtech.proj4j.CRSFactory;
import org.locationtech.proj4j.CoordinateReferenceSystem;
import org.locationtech.proj4j.CoordinateTransform;
import org.locationtech.proj4j.CoordinateTransformFactory;
import org.locationtech.proj4j.ProjCoordinate;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;

@Controller
public class HomeController {
    
    private static final Logger logger = LoggerFactory.getLogger(HomeController.class);

    @RequestMapping(value = "/", method = RequestMethod.GET)
    public String home(Locale locale, Model model) {
        logger.info("Welcome home! The client locale is {}.", locale);

        // 현재 시간 설정 (기존 코드 유지)
        Date date = new Date();
        DateFormat dateFormat = DateFormat.getDateTimeInstance(DateFormat.LONG, DateFormat.LONG, locale);
        String formattedDate = dateFormat.format(date);
        model.addAttribute("serverTime", formattedDate);
        
        // TM 중부 원점 좌표 설정 (GIS_X_COOR, GIS_Y_COOR 값)
        double tmX = 547434.20000;  // TM 중부 원점 좌표의 X 값
        double tmY = 302138.00000;  // TM 중부 원점 좌표의 Y 값302138.00000

        // 좌표 변환 설정
        CRSFactory factory = new CRSFactory();
        CoordinateReferenceSystem tmCrs = factory.createFromName("epsg:5179"); // TM 중부 좌표계
        CoordinateReferenceSystem wgs84Crs = factory.createFromName("epsg:4326"); // WGS84 위경도 좌표계

        // 좌표 변환 객체 생성
        CoordinateTransformFactory transformFactory = new CoordinateTransformFactory();
        CoordinateTransform transform = transformFactory.createTransform(tmCrs, wgs84Crs);

        // 좌표 변환 수행
        ProjCoordinate srcCoord = new ProjCoordinate(tmX, tmY); // 원본 TM 중부 좌표
        ProjCoordinate destCoord = new ProjCoordinate(); // 변환된 좌표 결과 저장

        transform.transform(srcCoord, destCoord); // 변환 수행
        System.out.println(destCoord.y);
        System.out.println(destCoord.x);
        
        // 변환된 위경도 좌표를 JSP로 전달
        model.addAttribute("latitude", destCoord.y);   // 변환된 위도
        model.addAttribute("longitude", destCoord.x);  // 변환된 경도

        return "home"; // home.jsp
    }
}
