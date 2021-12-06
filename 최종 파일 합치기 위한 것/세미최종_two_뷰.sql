--------------------------------------------------------------------
--○ 관리자가 모든학생들의 모든 수강과목에 대한 
-- 학생명, 과정명, 수강과목, 출결점수, 실기점수, 필기점수, 총점, 중도하차여부
--------------------------------------------------------------------
CREATE OR REPLACE VIEW VIEW_STUDENT_INFO
AS
SELECT T1.학생명, T1.과정명, T1.수강과목, T1.출결점수, T1.실기점수, T1.필기점수
     , (T1.출결점수 + T1.실기점수 + T1.필기점수) "총점", T1.중도하차여부
FROM
(
    SELECT ST.NAME"학생명",CO.COUR_CODE"과정명" 
        , SU.NAME "수강과목"
        , FN_SCORE_ATTEND(GR.GRADE_CODE) "출결점수"
        , FN_SCORE_PRACTICE(GR.GRADE_CODE) "실기점수"
        , FN_SCORE_WRITTEN(GR.GRADE_CODE) "필기점수"
        , FN_QUIT(RE.REG_CODE) "중도하차여부"
    FROM TBL_STUDENT ST LEFT JOIN TBL_REGIST RE
            ON ST.STU_ID = RE.STU_ID
           LEFT JOIN TBL_COURSE CO
            ON RE.COUR_CODE = CO.COUR_CODE
           LEFT JOIN TBL_OPSUBJECT OP
            ON CO.COUR_CODE = OP.COUR_CODE
           LEFT JOIN TBL_SUBJECTS SU 
            ON OP.SUB_CODE = SU.SUB_CODE 
           LEFT JOIN TBL_GRADE GR
            ON OP.OPSUB_CODE = GR.OPSUB_CODE
            AND RE.REG_CODE = GR.REG_CODE

)T1;

--조회
SELECT *   
FROM VIEW_STUDENT_INFO;

SELECT *
FROM TAB;


----------------------------------------------------------------
--○ 관리자) 개설 과목 조회 VIEW 생성 (VIEW_OPSUBJECT)
-- 모든 과목의 정보 조회
-- 출력 : 과정명, 강의실, 과목명, 과목SDATE, 과목EDATE, 교재, 교수명
-- 개설과목(과정명), 강의실(강의실이름), 개설과목(과목명), 개설과목(시작일,끝일)
-- , 과목(교재명), 교수(교수명)
----------------------------------------------------------------
CREATE OR REPLACE VIEW VIEW_OPSUBJECT
AS
SELECT O.COUR_CODE "과정명", CR.NAME "강의실", S.NAME "과목명"
    , O.STARTDATE "과목시작일", O.ENDDATE "과목종료일", S.BOOK "교재명", P.NAME "교수명"
FROM TBL_OPSUBJECT O LEFT JOIN TBL_SUBJECTS S
ON O.SUB_CODE = S.SUB_CODE
    LEFT JOIN TBL_PROFESSOR P
    ON O.PRO_ID = P. PRO_ID
    LEFT JOIN TBL_COURSE C
    ON O.COUR_CODE = C.COUR_CODE
    LEFT JOIN TBL_CLASSROOM CR
    ON C.CLASS_CODE = CR.CLASS_CODE;
    

--조회
SELECT * FROM VIEW_OPSUBJECT;


----------------------------------------------------------------
--○ 관리자가 교수 과목 조회 하는 VIEW 생성 (VIEW_PROFESSOR_COUR)

-- 교수자 과목 조회 (모든 교수자에 대한 정보 출력)
-- 교수명, 배정과목, 과목SDATE, 과목EDATE, 교재명, 강의실, 강의 진행 여부
-- 교수, 과목, 개설과목, 과정, 강의실
-- 강의 진행 여부 (FN_LECTUR) 함수 사용
----------------------------------------------------------------
CREATE OR REPLACE VIEW VIEW_PROFESSOR_COUR
AS
SELECT P.NAME "교수명", O.COUR_CODE "배정과목", O.STARTDATE "과목시작일", O.ENDDATE "과목종료일"
     , S.BOOK "교재명", R.NAME "강의실", FN_COURSE(C.COUR_CODE) "강의진행여부"
FROM TBL_PROFESSOR P LEFT JOIN TBL_OPSUBJECT O
ON P.PRO_ID = O.PRO_ID
    LEFT JOIN TBL_SUBJECTS S
    ON O.SUB_CODE = S.SUB_CODE
    LEFT JOIN TBL_COURSE C
    ON O.COUR_CODE = C.COUR_CODE
    LEFT JOIN TBL_CLASSROOM R
    ON C.CLASS_CODE = R.CLASS_CODE;


-- 조회    
SELECT * FROM VIEW_PROFESSOR_COUR;



----------------------------------------
--○ 관리자가 개설된 과정 조회 하는 VIEW 생성 (VIEW_PROFESSOR_COUR)
-- 과정 정보 뷰 생성 
----------------------------------------
CREATE OR REPLACE VIEW VIEW_COURSE
AS
SELECT CO.COUR_CODE"과정명", CL.CAPACITY "강의실" , SU.NAME"과목명"
     , CO.STARTDATE"시작일",CO.ENDDATE"종료일", SU.BOOK"교재이름", PRO.NAME"교수자명"     
     , FN_COURSE(CO.COUR_CODE)"강의진행여부"
FROM TBL_PROFESSOR PRO RIGHT JOIN TBL_OPSUBJECT OP
ON PRO.PRO_ID = OP.PRO_ID
    LEFT JOIN TBL_SUBJECTS SU ON OP.SUB_CODE = SU.SUB_CODE
    RIGHT JOIN TBL_COURSE CO ON CO.COUR_CODE = OP.COUR_CODE
    LEFT JOIN TBL_CLASSROOM CL ON CL.CLASS_CODE = CO.CLASS_CODE;
 
-- 
SELECT * FROM VIEW_COURSE;    


---------------------------------
--○ 교수자 정보 뷰 생성 
----------------------------------
-- 교수자 과목 성적 조회
-- 과목명, 과목 SDATE, 과목EDATE, 교재이름, 학생이름, 출결, 실기, 필기, 총점, 등수

CREATE OR REPLACE VIEW VIEW_PROFESSOR
AS
SELECT T.교수명, T.과정명, T.과목명, T.과목시작일, T.과목종료일, T.교재이름, T.학생이름, T.출결, T.실기
     , T.필기,(T.출결점수 + T.필기점수 + T.실기점수)"총점"
     , RANK() OVER(PARTITION BY T.과정명, T.과목명 ORDER BY (T.출결점수 + T.필기점수 + T.실기점수)DESC)"등수"
     , T.중도하차     
FROM ( 
       SELECT PRO.NAME"교수명", SU.NAME"과목명", OP.STARTDATE"과목시작일", OP.ENDDATE"과목종료일", SU.BOOK"교재이름"
             , ST.NAME"학생이름", GR.ATTEND"출결", GR.PRACTICE"실기", GR.WRITTEN"필기"
             , FN_SCORE_PRACTICE(GR.GRADE_CODE)"실기점수"
             , FN_SCORE_WRITTEN(GR.GRADE_CODE)"필기점수"
             , FN_SCORE_ATTEND(GR.GRADE_CODE)"출결점수"
             , OP.COUR_CODE"과정명"
             , FN_QUIT(RE.REG_CODE)"중도하차"
  
        FROM TBL_OPSUBJECT OP LEFT JOIN TBL_PROFESSOR PRO
        ON PRO.PRO_ID = OP.PRO_ID
            LEFT JOIN TBL_SUBJECTS SU ON SU.SUB_CODE = OP.SUB_CODE
            LEFT JOIN TBL_GRADE GR ON GR.OPSUB_CODE = OP.OPSUB_CODE
            LEFT JOIN TBL_REGIST RE ON RE.REG_CODE = GR.REG_CODE
            LEFT JOIN TBL_STUDENT ST ON ST.STU_ID = RE.STU_ID    
)T;

-- 테스트
-- 그냥 조회 할 경우 다 뜸
SELECT * 
FROM VIEW_PROFESSOR;

-- WHERE 절로 중도하차 빼기
SELECT * 
FROM VIEW_PROFESSOR
WHERE 중도하차 <> '중도하차';



----------------------------------------
--○ 학생) 성적 조회 VIEW 생성 (VIEW_STUDENT_GRADE)
-- 출력정보 : 학생명, 과정명, 과목명, 교육기간(시작,끝 날짜), 교재명
--           , 출결, 필기, 실기, 총점, 등수
-- 학생(학생명), 수강신청(과정명), 개설과목(과목명), 과정(시작,끝날짜), 과목(교재명)
--           , 성적(출결, 실기, 필기, 총점, 등수) -> 함수예정 (과목별 성적 출력)
----------------------------------------
CREATE OR REPLACE VIEW VIEW_STUDENT_GRADE
AS
SELECT T2.학생명, T2.과정명, T2.과목명, T2.과정시작일, T2.과정종료일, T2.교재명
    , T2.출결점수, T2.필기점수, T2.실기점수, T2.총점
    , RANK() OVER(PARTITION BY T2.과정명, T2.과목명 ORDER BY T2.총점 DESC) "등수"
FROM
(
    SELECT T1.학생명, T1.과정명, T1.과목명, T1.과정시작일, T1.과정종료일, T1.교재명
        , T1.출결점수, T1.필기점수, T1.실기점수, (T1.출결점수 + T1.필기점수 + T1.실기점수) "총점"
    FROM
    (
    SELECT S.NAME "학생명", R.COUR_CODE "과정명", SJ.NAME "과목명"
         , C.STARTDATE "과정시작일", C.ENDDATE "과정종료일", SJ.BOOK "교재명"
    
         , FN_SCORE_PRACTICE(G.GRADE_CODE) "실기점수"
         , FN_SCORE_WRITTEN(G.GRADE_CODE) "필기점수"
         , FN_SCORE_ATTEND(G.GRADE_CODE) "출결점수"   
    FROM TBL_STUDENT S LEFT JOIN TBL_REGIST R
    ON S.STU_ID = R.STU_ID
        LEFT JOIN TBL_COURSE C
        ON R.COUR_CODE = C.COUR_CODE
        LEFT JOIN TBL_OPSUBJECT O
        ON C.COUR_CODE = O.COUR_CODE
        LEFT JOIN TBL_SUBJECTS SJ
        ON O.SUB_CODE = SJ.SUB_CODE
        JOIN TBL_GRADE G
        ON O.OPSUB_CODE = G.OPSUB_CODE  AND R.REG_CODE = G.REG_CODE
    ) T1
) T2;

    
-- 조회
SELECT *
FROM VIEW_STUDENT_GRADE;

