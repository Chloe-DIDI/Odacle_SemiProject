--◈ 뷰 VIEW 생성

---------------------------------
     교수자 정보 뷰 생성 
----------------------------------
-- 교수자 과목 성적 조회
-- 과목명, 과목 SDATE, 과목EDATE, 교재이름, 학생이름, 출결, 실기, 필기, 총점, 등수

CREATE OR REPLACE VIEW VIEW_PROFESSOR
AS


SELECT T.교수명, T.과정명, T.과목명, T.과목시작일, T.과목종료일, T.교재이름, T.학생이름, T.출결, T.실기
     , T.필기,(T.출결점수 + T.필기점수 + T.실기점수)"총점"
     , RANK() OVER(PARTITION BY T.과정명, T.과목명 ORDER BY (T.출결점수 + T.필기점수 + T.실기점수)DESC)"등수"
     
FROM ( 
       SELECT PRO.NAME"교수명", SU.NAME"과목명", OP.STARTDATE"과목시작일", OP.ENDDATE"과목종료일", SU.BOOK"교재이름"
             , ST.NAME"학생이름", GR.ATTEND"출결", GR.PRACTICE"실기", GR.WRITTEN"필기"
             , FN_SCORE_PRACTICE(GR.GRADE_CODE)"실기점수"
             , FN_SCORE_WRITTEN(GR.GRADE_CODE)"필기점수"
             , FN_SCORE_ATTEND(GR.GRADE_CODE)"출결점수"
             , OP.COUR_CODE"과정명"
  
FROM TBL_OPSUBJECT OP LEFT JOIN TBL_PROFESSOR PRO
        ON PRO.PRO_ID = OP.PRO_ID
            LEFT JOIN TBL_SUBJECTS SU ON SU.SUB_CODE = OP.SUB_CODE
            LEFT JOIN TBL_GRADE GR ON GR.OPSUB_CODE = OP.OPSUB_CODE
            LEFT JOIN TBL_REGIST RE ON RE.REG_CODE = GR.REG_CODE
            LEFT JOIN TBL_STUDENT ST ON ST.STU_ID = RE.STU_ID
)T;











----------------------------------------
          과정 정보 뷰 생성 
----------------------------------------

CREATE OR REPLACE VIEW VIEW_COURSE
AS

SELECT CO.COUR_CODE"과정명", CO.CLASS_CODE"강의실번호", SU.NAME"과목명"
     , CO.STARTDATE"시작일",CO.ENDDATE"종료일", SU.BOOK"교재이름", PRO.NAME"교수자명"
     , CL.CAPACITY"강의실 정보"
     , FN_COURSE(CO.COUR_CODE)"강의진행여부"

FROM TBL_PROFESSOR PRO RIGHT JOIN TBL_OPSUBJECT OP
ON PRO.PRO_ID = OP.PRO_ID
    LEFT JOIN TBL_SUBJECTS SU ON OP.SUB_CODE = SU.SUB_CODE
    RIGHT JOIN TBL_COURSE CO ON CO.COUR_CODE = OP.COUR_CODE
    LEFT JOIN TBL_CLASSROOM CL ON CL.CLASS_CODE = CO.CLASS_CODE;
    
    
강의실번호가안나오고,,강의실 정보로 이으기
강의진행여부까지 넣어주기

