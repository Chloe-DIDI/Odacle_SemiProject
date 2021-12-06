--■■■ 관리자테이블

--관리자 입력 프로시저
CREATE OR REPLACE PROCEDURE PRC_ADMIN_INSERT
( V_ADMIN_ID    IN TBL_ADMIN.ADMIN_ID%TYPE
, V_PW          IN TBL_ADMIN.PW%TYPE
, V_NAME        IN TBL_ADMIN.NAME%TYPE
)
IS 
BEGIN
    INSERT INTO TBL_ADMIN(ADMIN_ID, PW, NAME) VALUES (V_ADMIN_ID, V_PW, V_NAME);
    
    COMMIT;
    
END;

-- 프로시저 호출
EXEC PRC_ADMIN_INSERT('ADMIN2020', '1234', '관리자');
EXEC PRC_ADMIN_INSERT('ADMIN1111', '12345', '관리자2');

------------------------------------------------------------------------

-- 관리자테이블 로그인 프로시저
CREATE OR REPLACE PROCEDURE PRC_ADMIN_LOGIN
( V_ADMIN_ID    IN TBL_ADMIN.ADMIN_ID%TYPE
, V_PW          IN TBL_ADMIN.PW%TYPE
)
IS
    V_ADMIN_ID2 TBL_ADMIN.ADMIN_ID%TYPE;
    V_PW2       TBL_ADMIN.PW%TYPE;
    V_IDCOUNT   NUMBER;
    USER_DEFINE_ERROR   EXCEPTION;
    USER_DEFINE_ERROR2   EXCEPTION;
BEGIN
    
    SELECT COUNT(*) INTO V_IDCOUNT 
    FROM TBL_ADMIN
    WHERE ADMIN_ID = V_ADMIN_ID;
    
    IF (V_IDCOUNT =0 )
        THEN RAISE USER_DEFINE_ERROR;
    END IF;
    
    SELECT PW INTO V_PW2
    FROM TBL_ADMIN
    WHERE ADMIN_ID = V_ADMIN_ID;
    

    IF (V_PW = V_PW2)
        THEN DBMS_OUTPUT.PUT_LINE('관리자 로그인');
    ELSE
        RAISE USER_DEFINE_ERROR2; 
    END IF;
   
    COMMIT;
    
    EXCEPTION
        WHEN USER_DEFINE_ERROR
            THEN RAISE_APPLICATION_ERROR(-20004,'아이디가 존재하지 않습니다.');
            ROLLBACK;
        WHEN USER_DEFINE_ERROR2
            THEN RAISE_APPLICATION_ERROR(-20005,'아이디와 패스워드가 일치하지 않습니다.');
            ROLLBACK;
END;


-- 프로시저 호출
EXEC PRC_ADMIN_LOGIN('ADMIN2020','1234'); -- ID, PW 일치할 때 
EXEC PRC_ADMIN_LOGIN('ADMIN1111','1234'); -- ID, PW 불일치할 때 
EXEC PRC_ADMIN_LOGIN('ADMIN1000','1234'); -- 존재하지 않는 ID 입력할 때


--=======================================================================================================

--■■■ 교수테이블

-- 교수 INSERT 프로시저 생성 (PRC_PROFESSOR_INSERT)
-- 예시) EXEC PRC_PROFESSOR_INSERT('아이디', '이름', '주민번호앞자리', '주민번호뒷자리')
CREATE OR REPLACE PROCEDURE PRC_PROFESSOR_INSERT
( V_PRO_ID  IN TBL_PROFESSOR.PRO_ID%TYPE
, V_NAME    IN TBL_PROFESSOR.NAME%TYPE
, V_FSSN    IN TBL_PROFESSOR.FSSN%TYPE
, V_BSSN    IN TBL_PROFESSOR.BSSN%TYPE
)
IS
    USER_DEFINE_ERROR   EXCEPTION;
    V_SSN       CHAR(13);       -- 입력받은 주민번호 앞뒤 담을 변수
    V2_SSN      CHAR(13);       -- 테이블의 주민번호 앞뒤 담을 변수
    
    V2_FSSN     TBL_PROFESSOR.FSSN%TYPE;
    V2_BSSN     TBL_PROFESSOR.BSSN%TYPE;
    
    CURSOR CUR_PROFESSOR_SELECT
    IS
    SELECT FSSN, BSSN
    FROM TBL_PROFESSOR;
BEGIN
    
    V_SSN := V_FSSN || V_BSSN;
    
    OPEN CUR_PROFESSOR_SELECT;
    LOOP
        FETCH CUR_PROFESSOR_SELECT INTO V2_FSSN, V2_BSSN;
        V2_SSN := V2_FSSN || V2_BSSN;
        EXIT WHEN CUR_PROFESSOR_SELECT%NOTFOUND;
        
        IF(V_SSN = V2_SSN)
            THEN RAISE USER_DEFINE_ERROR;
        END IF;
    
    END LOOP;
    CLOSE CUR_PROFESSOR_SELECT;
       
    
    INSERT INTO TBL_PROFESSOR (PRO_ID, PW, NAME, FSSN, BSSN, SIGNDATE)
        VALUES (V_PRO_ID, V_BSSN, V_NAME, V_FSSN, V_BSSN, SYSDATE);
    
    COMMIT;
    
    EXCEPTION
        WHEN USER_DEFINE_ERROR
            THEN RAISE_APPLICATION_ERROR(-20003,'주민번호가 중복됩니다. 다시 입력하세요.');
            ROLLBACK;     
        WHEN OTHERS
             THEN ROLLBACK;
END;

--프로시저 호출
EXEC PRC_PROFESSOR_INSERT('uskwak', '곽우신', '821201', '1111112');

------------------------------------------------------------------------

--교수테이블 PW변경 프로시저
CREATE OR REPLACE PROCEDURE PRC_PRO_PW_UPDATE
( V_ID            IN TBL_PROFESSOR.PRO_ID%TYPE
, V_PW            IN TBL_PROFESSOR.PW%TYPE    --기존 패스워드
, V_NEWPW         IN TBL_PROFESSOR.PW%TYPE    --바꾸고 싶어하는 패스워드
)
IS
    V_PW2    TBL_PROFESSOR.PW%TYPE;
    
BEGIN 
 
    SELECT PW INTO V_PW2 
    FROM TBL_PROFESSOR
    WHERE PRO_ID = V_ID AND PW = V_PW;
         
    IF(V_PW = V_PW2)
        THEN
            UPDATE TBL_PROFESSOR
            SET PW =V_NEWPW
            WHERE PRO_ID = V_ID; 
    END IF;
    
    COMMIT;       
                          
    EXCEPTION        --이게 아니라면 예외 
        WHEN OTHERS 
            THEN RAISE_APPLICATION_ERROR(-20005,'아이디와 패스워드가 일치하지 않습니다.');
        ROLLBACK;
END;


--프로시저 호출
EXEC PRC_PRO_PW_UPDATE('uskwak', 'newpassword', '1111112');

------------------------------------------------------------------------

-- 교수테이블 로그인 프로시저
CREATE OR REPLACE PROCEDURE PRC_PROFESSOR_LOGIN
( V_PRO_ID    IN TBL_PROFESSOR.PRO_ID%TYPE
, V_PW        IN TBL_PROFESSOR.PW%TYPE
)
IS
    V_PW2     TBL_PROFESSOR.PW%TYPE;
    V_IDCOUNT   NUMBER;
    USER_DEFINE_ERROR   EXCEPTION;
    USER_DEFINE_ERROR2   EXCEPTION; 
BEGIN
    
    SELECT COUNT(*) INTO V_IDCOUNT 
    FROM TBL_PROFESSOR
    WHERE PRO_ID = V_PRO_ID;
    
    IF (V_IDCOUNT =0 )
        THEN RAISE USER_DEFINE_ERROR;
    END IF;
    
    SELECT PW INTO V_PW2
     FROM TBL_PROFESSOR
    WHERE PRO_ID = V_PRO_ID;

    IF (V_PW = V_PW2)
        THEN DBMS_OUTPUT.PUT_LINE('교수자 로그인');
    ELSE
        RAISE USER_DEFINE_ERROR2; 
    END IF;
   
    COMMIT;
    
    EXCEPTION
        WHEN USER_DEFINE_ERROR
            THEN RAISE_APPLICATION_ERROR(-20004,'아이디가 존재하지 않습니다.');
            ROLLBACK;
        WHEN USER_DEFINE_ERROR2
            THEN RAISE_APPLICATION_ERROR(-20005,'아이디와 패스워드가 일치하지 않습니다.');
            ROLLBACK;
END;

--프로시저 호출
EXEC PRC_PROFESSOR_LOGIN('hjkim','1234567');


------------------------------------------------------------------------

--교수 정보 수정 프로시저 (이름, 주민번호, 가입날짜 변경)
CREATE OR REPLACE PROCEDURE PRC_PROFESSOR_UPDATE
( V_PRO_ID   IN TBL_PROFESSOR.PRO_ID%TYPE
, V_NAME     IN TBL_PROFESSOR.NAME%TYPE
, V_FSSN     IN TBL_PROFESSOR.FSSN%TYPE
, V_BSSN     IN TBL_PROFESSOR.BSSN%TYPE
, V_SIGNDATE IN TBL_PROFESSOR.SIGNDATE%TYPE
)
IS
    V_IDCOUNT   NUMBER;
    USER_DEFINE_ERROR EXCEPTION;
    USER_DEFINE_ERROR2 EXCEPTION;
BEGIN
    SELECT COUNT(*) INTO V_IDCOUNT
    FROM TBL_PROFESSOR
    WHERE PRO_ID = V_PRO_ID;
    
    IF (V_IDCOUNT = 0)
        THEN RAISE USER_DEFINE_ERROR;
    END IF;
    
    
    SELECT COUNT(*) INTO V_IDCOUNT --중복된 정보 찾기 위해 
    FROM TBL_PROFESSOR
    WHERE NAME = V_NAME AND FSSN = V_FSSN AND BSSN = V_BSSN AND SIGNDATE = V_SIGNDATE;
    
    
    IF(V_IDCOUNT != 0)
        THEN RAISE USER_DEFINE_ERROR2;
    END IF;
    
    
    --UPDATE
    UPDATE TBL_PROFESSOR
    SET NAME = V_NAME, FSSN = V_FSSN, BSSN = V_BSSN, SIGNDATE = V_SIGNDATE
    WHERE PRO_ID = V_PRO_ID;
    
    COMMIT;

    EXCEPTION
        WHEN USER_DEFINE_ERROR
            THEN RAISE_APPLICATION_ERROR(-20004,'아이디가 존재하지 않습니다.');
            ROLLBACK;
        WHEN USER_DEFINE_ERROR2
            THEN RAISE_APPLICATION_ERROR(-20020,'이미 존재하는 교수정보 입니다!');
            ROLLBACK;

END;

--프로시저 호출
EXEC PRC_PROFESSOR_UPDATE( 'uskwak', '곽우신','821212','1111234',TO_DATE('2009-11-11', 'YYYY-MM-DD'));


------------------------------------------------------------------------
-- 교수 삭제 프로시저 생성 (PRC_PROFESSOR_DELETE)
-- 예시) EXEC PRC_PROFESSOR_DELETE('교수ID', '교수명')
-- 아이디 교수명 일치확인
-- 현재 강의중인 교수일 경우 삭제 불가
-- OPSUBJECT에 교수명이 일치한 모든 과목의 시작끝 날짜 가져와서 지금날짜랑 비교
-- 만약 현재 강의중이면 예외발생
-------------------------------------------------------------
CREATE OR REPLACE PROCEDURE PRC_PROFESSOR_DELETE
( V_PRO_ID  IN TBL_PROFESSOR.PRO_ID%TYPE
, V_NAME    IN TBL_PROFESSOR.NAME%TYPE
)
IS
    USER_DEFINE_ERROR1   EXCEPTION;
    USER_DEFINE_ERROR2   EXCEPTION;
    
    V2_PRO_ID   TBL_PROFESSOR.PRO_ID%TYPE;    --ID 확인후 담기용
    V2_NAME     TBL_PROFESSOR.NAME%TYPE;      --이름 확인후 담기용
     
    V3_PRO_ID   TBL_PROFESSOR.PRO_ID%TYPE; 
    V_STARTDATE TBL_OPSUBJECT.STARTDATE%TYPE;   --시작일
    V_ENDDATE   TBL_OPSUBJECT.ENDDATE%TYPE;      --종료일    
    
    CURSOR CUR_PROFESSOR_SELECT
    IS
    SELECT PRO_ID, STARTDATE, ENDDATE
    FROM TBL_OPSUBJECT;    
BEGIN
        
    -- 교수테이블 정보 담기
    SELECT (
        SELECT PRO_ID
        FROM TBL_PROFESSOR
        WHERE PRO_ID = V_PRO_ID AND NAME = V_NAME) INTO V2_PRO_ID
    FROM DUAL;
    
    SELECT (
        SELECT NAME 
        FROM TBL_PROFESSOR
        WHERE PRO_ID = V_PRO_ID AND NAME = V_NAME) INTO V2_NAME
    FROM DUAL;
    
    -- 일치한 데이터 없을경우 에러 발생
    IF(V2_PRO_ID IS NULL)
        THEN RAISE USER_DEFINE_ERROR1;
    END IF;
    
    
    --TBL_OPSUBJECT 테이블 내 교수강의 내역 다 조회 후 날짜 확인
    OPEN CUR_PROFESSOR_SELECT;
    LOOP
        FETCH CUR_PROFESSOR_SELECT INTO V3_PRO_ID, V_STARTDATE, V_ENDDATE;
        EXIT WHEN CUR_PROFESSOR_SELECT%NOTFOUND;
        
        IF(V3_PRO_ID = V2_PRO_ID)
            THEN DELETE
                 FROM TBL_OPSUBJECT
                 WHERE V3_PRO_ID = V2_PRO_ID;
                 
            IF((V_STARTDATE < SYSDATE) AND (V_ENDDATE >SYSDATE))
                THEN RAISE USER_DEFINE_ERROR2; 
            END IF;
        END IF;
    END LOOP;
    CLOSE CUR_PROFESSOR_SELECT;         
                           
    -- PROFESSOR 테이블에 교수 데이터 삭제
    DELETE 
    FROM TBL_PROFESSOR
    WHERE PRO_ID = V2_PRO_ID AND NAME = V2_NAME;
    
    COMMIT;
    
    -- 테스트 출력
    DBMS_OUTPUT.PUT_LINE('삭제한 교수ID/교수명 : '|| V2_PRO_ID||'/'||V2_NAME);
    
    EXCEPTION
        WHEN USER_DEFINE_ERROR1
            THEN RAISE_APPLICATION_ERROR(-20011,'일치하는 데이터가 없습니다.');
            ROLLBACK;
        WHEN USER_DEFINE_ERROR2
            THEN RAISE_APPLICATION_ERROR(-20012,'현재 강의 중인 교수는 삭제 할 수 없습니다.');
            ROLLBACK;
        WHEN OTHERS
             THEN ROLLBACK;
END;

--프로시저 호출
EXEC PRC_PROFESSOR_DELETE('uskwak' , '곽우신');

--=======================================================================================================

--■■■ 학생테이블

-- 학생테이블 INSERT 프로시져
CREATE OR REPLACE PROCEDURE PRC_STUDENT_INSERT
( V_STU_ID      IN TBL_STUDENT.STU_ID%TYPE
, V_NAME        IN TBL_STUDENT.NAME%TYPE
, V_FSSN        IN TBL_STUDENT.FSSN%TYPE
, V_BSSN        IN TBL_STUDENT.BSSN%TYPE
)
IS
    V_SSN CHAR(13);  --매개변수로 받은 주민번호 변수
    V_SSN2 CHAR(13); --커서로가져온 값들을 담는 주민번호 변수 
    
    V_FSSN2 TBL_STUDENT.FSSN%TYPE; --커서사용변수
    V_BSSN2 TBL_STUDENT.BSSN%TYPE; --커서사용변수
    
    USER_DEFINE_ERROR EXCEPTION;
    
    CURSOR CUR_STUDENT_SELECT
    IS
    SELECT FSSN, BSSN
    FROM TBL_STUDENT;
    
BEGIN
    V_SSN := V_FSSN || V_BSSN; 

    OPEN CUR_STUDENT_SELECT;   
    LOOP
        FETCH CUR_STUDENT_SELECT INTO V_FSSN2, V_BSSN2; 
	V_SSN2 := V_FSSN2 || V_BSSN2; 
        EXIT WHEN CUR_STUDENT_SELECT%NOTFOUND;

   	 -- 주민번호 중복시 에러발생
    	IF(V_SSN = V_SSN2)
        	THEN RAISE USER_DEFINE_ERROR;
    	END IF;

    END LOOP;
    CLOSE CUR_STUDENT_SELECT;
    
    -- INSERT 구문
    INSERT INTO TBL_STUDENT(STU_ID, PW, NAME, FSSN, BSSN, SIGNDATE)
    VALUES (V_STU_ID, V_BSSN, V_NAME, V_FSSN, V_BSSN, SYSDATE);
    
    COMMIT;
    
    EXCEPTION  
        WHEN USER_DEFINE_ERROR
            THEN RAISE_APPLICATION_ERROR(-20004,'주민번호가 중복됩니다. 다시 입력하세요.');
            ROLLBACK;
        WHEN OTHERS
             THEN ROLLBACK;
END;

--프로시저 호출
EXEC PRC_STUDENT_INSERT('201402013', '송해덕', '950212', '1735914');

------------------------------------------------------------------------

--학생테이블 PW변경 프로시저

CREATE OR REPLACE PROCEDURE PRC_STUDENT_UPDATE
( V_ID            IN TBL_STUDENT.STU_ID%TYPE   --기존 아이디
, V_PW            IN TBL_STUDENT.PW%TYPE       --기존 패스워드
, V_NEWPW         IN TBL_STUDENT.PW%TYPE       --바꾸고 싶어하는 패스워드
)
IS
    V_PW2    TBL_STUDENT.PW%TYPE;    
BEGIN 

    SELECT PW INTO V_PW2 
    FROM TBL_STUDENT
    WHERE STU_ID = V_ID;
         
    IF(V_PW = V_PW2)      
        THEN
            UPDATE TBL_STUDENT
            SET PW =V_NEWPW
            WHERE STU_ID = V_ID;     
    END IF;
    
    COMMIT;
                          
    EXCEPTION         
        WHEN OTHERS 
            THEN RAISE_APPLICATION_ERROR(-20005,'아이디와 패스워드가 일치하지 않습니다.');
    ROLLBACK;

END;


--프로시저 호출
EXEC PRC_STUDENT_UPDATE('201402013', '1735914', 'newpassword');

------------------------------------------------------------------------

-- 학생테이블 로그인 프로시저
CREATE OR REPLACE PROCEDURE PRC_STUDENT_LOGIN
( V_STU_ID    IN TBL_STUDENT.STU_ID%TYPE
, V_PW        IN TBL_STUDENT.PW%TYPE
)
IS
    V_PW2     TBL_STUDENT.PW%TYPE;
    V_IDCOUNT   NUMBER;
    USER_DEFINE_ERROR   EXCEPTION;
    USER_DEFINE_ERROR2   EXCEPTION;  
BEGIN

    SELECT COUNT(*) INTO V_IDCOUNT 
    FROM TBL_STUDENT
    WHERE STU_ID = V_STU_ID;
    
    IF ( V_IDCOUNT = 0 )
        THEN RAISE USER_DEFINE_ERROR;
    END IF;
    
    SELECT PW INTO V_PW2
    FROM TBL_STUDENT
    WHERE STU_ID = V_STU_ID ;
    
    IF (V_PW = V_PW2)
        THEN DBMS_OUTPUT.PUT_LINE('학생 로그인');
    ELSE
        RAISE USER_DEFINE_ERROR2; 
    END IF;
   
    COMMIT;
    
    EXCEPTION
        WHEN USER_DEFINE_ERROR
            THEN RAISE_APPLICATION_ERROR(-20004,'아이디가 존재하지 않습니다.');
            ROLLBACK;
        WHEN USER_DEFINE_ERROR2
            THEN RAISE_APPLICATION_ERROR(-20005,'아이디와 패스워드가 일치하지 않습니다.');
            ROLLBACK;
END;

--프로시저 호출
EXEC PRC_STUDENT_LOGIN('201305047','2145789');


------------------------------------------------------------------------

-- 학생테이블에서 데이터 삭제 시 발동하는 트리거 생성 
CREATE OR REPLACE TRIGGER TRG_STUDENT_DELETE    -->> 안되면 SYS 가서 GRANT CREATE TRIGGER TO two; 하면 된다!
        BEFORE
        DELETE ON TBL_STUDENT
        FOR EACH ROW
BEGIN
    DELETE
    FROM TBL_REGIST
    WHERE STU_ID = :OLD.STU_ID;
END;

----------------------------------------------------
-- 학생 삭제 프로시저 
-- 예시) EXEC PRC_STUDENT_DELETE('학생ID', '학생명')
-- 중도하차 테이블에 데이터가 있는 학생은 삭제 불가 
-- 현재 수강중인 학생 삭제 불가
-- 학생 삭제 시 수강신청 테이블에서 삭제 트리거 같이 돌아야 함
CREATE OR REPLACE PROCEDURE PRC_STUDENT_DELETE
( V_STU_ID  IN TBL_STUDENT.STU_ID%TYPE
, V_NAME    IN TBL_STUDENT.NAME%TYPE
)
IS
    USER_DEFINE_ERROR1   EXCEPTION;
    USER_DEFINE_ERROR2   EXCEPTION;
    V2_STU_ID   TBL_STUDENT.STU_ID%TYPE;    --ID 확인후 담기용
    V2_NAME     TBL_STUDENT.NAME%TYPE;      --이름 확인후 담기용
     
    V_COUR_CODE TBL_REGIST.COUR_CODE%TYPE;  --과정명    
    V_REG_CODE  TBL_QUIT.REG_CODE%TYPE;     --수강신청코드
    
    V_STARTDATE TBL_COURSE.STARTDATE%TYPE;  --시작일
    V_ENDDATE TBL_COURSE.ENDDATE%TYPE;      --종료일
    
BEGIN
        
    -- 학생테이블 정보 담기
    SELECT STU_ID, NAME INTO V2_STU_ID, V2_NAME
    FROM TBL_STUDENT
    WHERE STU_ID = V_STU_ID AND NAME = V_NAME;
       
    --중도하차 테이블에 학생 정보가 있는지 확인
    SELECT( SELECT REG_CODE
            FROM TBL_QUIT
            WHERE REG_CODE = ( SELECT REG_CODE
                               FROM TBL_REGIST
                               WHERE STU_ID = V2_STU_ID)) INTO V_REG_CODE
    FROM DUAL;
                        
    --중도 하차한 학생일 경우 에러발생
    IF(V_REG_CODE IS NOT NULL)
        THEN RAISE USER_DEFINE_ERROR1;
             --COMMIT;
    END IF; 
                        
    -- 학생 수강신청 여부 조회한 다음 시작, 종료일 담음
    SELECT( SELECT STARTDATE
            FROM TBL_COURSE
            WHERE COUR_CODE = ( SELECT COUR_CODE 
                                FROM TBL_REGIST
                                WHERE STU_ID = V_STU_ID )) INTO V_STARTDATE
    FROM DUAL;
    
    SELECT( SELECT ENDDATE
            FROM TBL_COURSE
            WHERE COUR_CODE = ( SELECT COUR_CODE 
                                FROM TBL_REGIST
                                WHERE STU_ID = V_STU_ID )) INTO  V_ENDDATE 
    FROM DUAL;
    
    -- 만약 진행중인 과정일 경우 에러 발생
    IF((V_STARTDATE < SYSDATE) AND (V_ENDDATE >SYSDATE))
        THEN RAISE USER_DEFINE_ERROR2;  
    END IF;
     
    -- STUDENT 테이블에 학생정보 삭제
    DELETE 
    FROM TBL_STUDENT
    WHERE STU_ID = V2_STU_ID AND NAME = V2_NAME;
    
    -- 삭제한 학생 정보 출력
    DBMS_OUTPUT.PUT_LINE('삭제한 학생의 ID/학생명 : '|| V_STU_ID||'/'||V_NAME);
    
    COMMIT;
    
    EXCEPTION
        WHEN USER_DEFINE_ERROR1
            THEN RAISE_APPLICATION_ERROR(-20013,'중도하차 이력 존재하여 삭제불가');
            ROLLBACK;
        WHEN USER_DEFINE_ERROR2
            THEN RAISE_APPLICATION_ERROR(-20014,'수강중인 학생으로 삭제할 수 없습니다.');
            ROLLBACK;
        WHEN OTHERS
            THEN ROLLBACK;
END;

--프로시저 호출
EXEC PRC_STUDENT_DELETE('201402013', '송해덕');


------------------------------------------------------------------------

-- 학생 수정 프로시저
-- 관리자는 학생의 정보 NAME, FSSN, BSSN,PW,SIGNDATE 를 변경할 수 있다. 
CREATE OR REPLACE PROCEDURE PRC_STUDENT_UPDATE
(
  V_STU_ID   IN TBL_STUDENT.STU_ID%TYPE
, V_NAME     IN TBL_STUDENT.NAME%TYPE
, V_FSSN     IN TBL_STUDENT.FSSN%TYPE
, V_BSSN     IN TBL_STUDENT.BSSN%TYPE
, V_SIGNDATE IN TBL_STUDENT.SIGNDATE%TYPE
)
IS
    V_IDCOUNT   NUMBER;
    USER_DEFINE_ERROR EXCEPTION;
    USER_DEFINE_ERROR2 EXCEPTION;
BEGIN
    SELECT COUNT(*) INTO V_IDCOUNT
    FROM TBL_STUDENT
    WHERE STU_ID = V_STU_ID;
    
    IF (V_IDCOUNT = 0) --입력한 학생 ID가 없을시 에러 
        THEN RAISE USER_DEFINE_ERROR;
    END IF;
    
    SELECT COUNT(*) INTO V_IDCOUNT --중복된 정보 찾기 위해 
    FROM TBL_STUDENT
    WHERE NAME = V_NAME AND FSSN = V_FSSN AND BSSN = V_BSSN AND SIGNDATE = V_SIGNDATE;
    
    
    IF(V_IDCOUNT != 0)
        THEN RAISE USER_DEFINE_ERROR2;
    END IF;
        
    
    --UPDATE
    UPDATE TBL_STUDENT
    SET NAME = V_NAME, FSSN = V_FSSN, BSSN = V_BSSN, SIGNDATE = V_SIGNDATE
    WHERE STU_ID = V_STU_ID;
    
    COMMIT;

    EXCEPTION
        WHEN USER_DEFINE_ERROR
            THEN RAISE_APPLICATION_ERROR(-20004,'아이디가 존재하지 않습니다.');
            ROLLBACK;
        WHEN USER_DEFINE_ERROR2
            THEN RAISE_APPLICATION_ERROR(-20020,'이미 존재하는 학생정보 입니다!');
            ROLLBACK;
    

END;

EXEC PRC_STUDENT_UPDATE('201402013','송해덕','950212','1735914',TO_DATE('2020-09-25', 'YYYY-MM-DD'));

--=======================================================================================================

--■■■ 강의실 테이블

--강의실 입력 프로시저
CREATE OR REPLACE PROCEDURE PRC_CLASSROOM_INSERT
( V_CLASS_CODE     IN TBL_CLASSROOM.CLASS_CODE%TYPE
, V_NAME          IN TBL_CLASSROOM.NAME%TYPE
, V_CAPACITY      IN TBL_CLASSROOM.CAPACITY%TYPE
)
IS
BEGIN
    INSERT INTO TBL_CLASSROOM(CLASS_CODE,NAME,CAPACITY) VALUES(V_CLASS_CODE,V_NAME,V_CAPACITY);
    
    COMMIT;
END;

--프로시저 확인
EXEC PRC_CLASSROOM_INSERT(7,'공학관R101','강의실1층 수용인원15명');

--=======================================================================================================

--■■■ 배점 테이블

--배점 입력 프로시저
CREATE OR REPLACE PROCEDURE PRC_ALLOT_INSERT
( V_ATTEND        IN TBL_ALLOT.ATTEND%TYPE
, V_PRACTICE      IN TBL_ALLOT.PRACTICE%TYPE
, V_WRITTEN       IN TBL_ALLOT.WRITTEN%TYPE
)
IS
    V_ALLOT_CODE    TBL_ALLOT.ALLOT_CODE%TYPE;
    USER_DEFINE_ERROR   EXCEPTION;
    V_ALLOT         VARCHAR2(20);  --비율 검사 문자열 담을 변수 
    
    CURSOR CUR_ALLOT_SELECT
    IS
    SELECT ATTEND||PRACTICE||WRITTEN
    FROM TBL_ALLOT;
    
BEGIN

    SELECT NVL(MAX(ALLOT_CODE),0) +1 INTO V_ALLOT_CODE
    FROM TBL_ALLOT;
    
    OPEN CUR_ALLOT_SELECT;
    
    LOOP
        
        FETCH CUR_ALLOT_SELECT INTO V_ALLOT; 
        
            -- 이미 똑같은 배점 비율이 있으면 예외 발생
            IF(V_ATTEND||V_PRACTICE||V_WRITTEN = V_ALLOT)
                THEN RAISE USER_DEFINE_ERROR;
            END IF;
        
        EXIT WHEN CUR_ALLOT_SELECT%NOTFOUND;
    END LOOP;
    
    CLOSE CUR_ALLOT_SELECT;
    
    --배점 INSERT 
    INSERT INTO TBL_ALLOT(ALLOT_CODE,ATTEND,PRACTICE,WRITTEN) 
    VALUES(V_ALLOT_CODE,V_ATTEND,V_PRACTICE,V_WRITTEN);
    
    EXCEPTION
        WHEN USER_DEFINE_ERROR
            THEN RAISE_APPLICATION_ERROR(-20002,'이미 존재하는 배점비율 입니다!');
            ROLLBACK;
    
    COMMIT;
END;

--프로시저 호출
EXEC PRC_ALLOT_INSERT(20, 50, 30);     

--=======================================================================================================

--■■■ 과목 테이블  

-- 과목 입력 프로시저
CREATE OR REPLACE PROCEDURE PRC_SUBJECTS_INSERT
(
  V_NAME    IN TBL_SUBJECTS.NAME%TYPE
, V_BOOK    IN TBL_SUBJECTS.BOOK%TYPE
)
IS 
    V_SUB_CODE  TBL_SUBJECTS.SUB_CODE%TYPE;
    SCOUNT          NUMBER;
    USER_DEFINE_ERROR   EXCEPTION;
    
BEGIN
    SELECT NVL(MAX(SUB_CODE),0) +1 INTO V_SUB_CODE
    FROM TBL_SUBJECTS;
    
    SELECT COUNT(*) INTO SCOUNT  --중복된 정보 찾기 위해 
    FROM TBL_SUBJECTS
    WHERE NAME = V_NAME AND BOOK = V_BOOK;
    
    
    IF(SCOUNT  != 0)
        THEN RAISE USER_DEFINE_ERROR;
    END IF;
    
    --입력
    INSERT INTO TBL_SUBJECTS(SUB_CODE, NAME, BOOK) 
    VALUES (V_SUB_CODE, V_NAME, V_BOOK);
    
    COMMIT;
    
    EXCEPTION
        WHEN USER_DEFINE_ERROR
            THEN RAISE_APPLICATION_ERROR(-20020,'이미 등록된 과목입니다!');
            ROLLBACK;
    
END;

--프로시저 호출
EXEC PRC_SUBJECTS_INSERT('파이썬', '파이썬이 최고다.');
--==>> 확인 완료

SELECT *
FROM TBL_SUBJECTS;

SELECT *
FROM TAB;
------------------------------------------------------------------------

--과목 수정 프로시저
CREATE OR REPLACE PROCEDURE PRC_SUB_UPDATE
(
   V_SUB_CODE  TBL_SUBJECTS.SUB_CODE%TYPE
  ,V_NAME    IN TBL_SUBJECTS.NAME%TYPE
  ,V_BOOK    IN TBL_SUBJECTS.BOOK%TYPE
)
IS
    SCOUNT   NUMBER;
    USER_DEFINE_ERROR   EXCEPTION;
    USER_DEFINE_ERROR2   EXCEPTION;
   
BEGIN
    --입력한 COUR_CODE가 유효한지 확인
    SELECT COUNT(*) INTO SCOUNT
    FROM TBL_SUBJECTS
    WHERE SUB_CODE = V_SUB_CODE;
    
    IF(SCOUNT = 0)
        THEN RAISE USER_DEFINE_ERROR;
    END IF;
    
    SELECT COUNT(*) INTO SCOUNT  --중복된 정보 찾기 위해 
    FROM TBL_SUBJECTS
    WHERE NAME = V_NAME AND BOOK = V_BOOK;
    
    
    IF(SCOUNT  != 0)
        THEN RAISE USER_DEFINE_ERROR2;
    END IF;
    
    --입력
    
    UPDATE TBL_SUBJECTS
    SET NAME = V_NAME, BOOK = V_BOOK
    WHERE SUB_CODE = V_SUB_CODE;
    
    --COMMIT;
    
    EXCEPTION
        WHEN USER_DEFINE_ERROR
            THEN RAISE_APPLICATION_ERROR(-20019,'존재하지 않는 과목코드입니다 !');
            ROLLBACK;
        WHEN USER_DEFINE_ERROR2
            THEN RAISE_APPLICATION_ERROR(-20020,'이미 등록된 과목입니다!');
            ROLLBACK;

END;

EXEC PRC_SUB_UPDATE(3, 'CSS', 'DO IT! CSS'); 
--==>> 확인 완료

--=======================================================================================================

--■■■ 과정 테이블  

-- 과정 입력 프로시저
CREATE OR REPLACE PROCEDURE PRC_COURSE_INSERT
( V_COUR_CODE     IN TBL_COURSE.COUR_CODE%TYPE      
, V_CLASS_CODE    IN TBL_COURSE.CLASS_CODE%TYPE
, V_STARTDATE     IN TBL_COURSE.STARTDATE%TYPE
, V_ENDDATE       IN TBL_COURSE.ENDDATE%TYPE
, V_LIMIT         IN TBL_COURSE.LIMIT%TYPE
) 
IS
    V_SD        TBL_COURSE.STARTDATE%TYPE;
    V_ED        TBL_COURSE.ENDDATE%TYPE;

    USER_DEFINE_ERROR EXCEPTION;
    
    CURSOR CUR_SDED_SELECT
    IS
    SELECT STARTDATE,ENDDATE
    FROM TBL_COURSE
    WHERE CLASS_CODE = V_CLASS_CODE;
    
BEGIN
    
     OPEN CUR_SDED_SELECT;
    
    LOOP
        
        FETCH CUR_SDED_SELECT INTO V_SD,V_ED; --강의실이 똑같은 과정의 날짜 뽑아냄        
        
        IF((V_SD <= V_STARTDATE AND V_STARTDATE <= V_ED) OR
           (V_SD <= V_ENDDATE AND V_ENDDATE <= V_ED) OR
            (V_STARTDATE <= V_SD AND V_ENDDATE > V_ED))
            THEN RAISE USER_DEFINE_ERROR;
        END IF;
        
        EXIT WHEN CUR_SDED_SELECT%NOTFOUND;
    END LOOP;
    
    --커서 클로즈
    CLOSE CUR_SDED_SELECT;
    
    INSERT INTO TBL_COURSE(COUR_CODE, CLASS_CODE, STARTDATE, ENDDATE,LIMIT)
    VALUES (V_COUR_CODE, V_CLASS_CODE, V_STARTDATE, V_ENDDATE,V_LIMIT);
    
    EXCEPTION
        WHEN USER_DEFINE_ERROR
            THEN RAISE_APPLICATION_ERROR(-20006,'입력하신 강의실은 해당기간에 사용 불가합니다!');
                 ROLLBACK;
    COMMIT;
        
END;

EXEC PRC_COURSE_INSERT('빅데이터B', 1, TO_DATE('2021-06-01', 'YYYY-MM-DD'), TO_DATE('2021-09-30', 'YYYY-MM-DD'), 25);

------------------------------------------------------------------------

-- 과정 삭제 프로시저
-- 개설 예정인 과정에 한해서 과정 삭제가 이루어지는 프로시저.
-- 수강신청은 자동 취소되며, 성적테이블에 과목이 등록된 데이터도 삭제된다.
CREATE OR REPLACE PROCEDURE PRC_COURSE_DELETE
(
    V_COUR_CODE    IN TBL_COURSE.COUR_CODE%TYPE
) 
IS 
    CCHECK         VARCHAR2(40);
    USER_DEFINE_ERROR   EXCEPTION;
    
    CURSOR CUR_COUR_REG
    IS
    SELECT REG_CODE 
    FROM TBL_REGIST
    WHERE COUR_CODE = V_COUR_CODE;
    
    V_REG_CODE       TBL_REGIST.REG_CODE%TYPE;
    
BEGIN
    
    SELECT FN_COURSE(COUR_CODE) INTO CCHECK --해당 과정의 진행상태 확인
    FROM TBL_COURSE
    WHERE COUR_CODE = V_COUR_CODE; 
    
    IF(CCHECK = '진행중' OR CCHECK = '과정 종료')
        THEN RAISE USER_DEFINE_ERROR;
    END IF;
    
    --자식들 삭제 과정
    --자식의 자식 삭제 --> 삭제하려는 과정을 수강신청해서 성적테이블에 올라온 것들 삭제     
    OPEN CUR_COUR_REG;
    
    LOOP
        FETCH CUR_COUR_REG INTO V_REG_CODE;
        
        DELETE
        FROM TBL_GRADE
        WHERE REG_CODE = V_REG_CODE;
    
        EXIT WHEN CUR_COUR_REG%NOTFOUND;
        
    END LOOP;
    
    CLOSE CUR_COUR_REG;

        
    --자식 삭제 - 수강신청 삭제 
    DELETE
    FROM TBL_REGIST
    WHERE COUR_CODE = V_COUR_CODE;
    
    -- 자식 삭제 - 개설과목 삭제 
    DELETE
    FROM TBL_OPSUBJECT
    WHERE COUR_CODE = V_COUR_CODE;
     
    --과정삭제 
    DELETE
    FROM TBL_COURSE
    WHERE COUR_CODE = V_COUR_CODE;
    
    COMMIT;
    
    EXCEPTION
        WHEN USER_DEFINE_ERROR
            THEN RAISE_APPLICATION_ERROR(-20015,'개설된 과정은 삭제 불가합니다.');
            ROLLBACK;             
END;

EXEC PRC_COURSE_DELETE('빅데이터B');

------------------------------------------------------------------------

--○ 과정 수정 프로시저
-- 과정이 시작 전(개설예정)인 것은 강의실,시작일,종강일 수정가능
-- 강의중 -> 강의실, 종강일 수정 
-- 강의종료 -> 수정 불가능 
-- PRC_COURSE_UPDATE('과정코드',강의실코드,시작날짜,종료날짜,제한인원)
-- 1. 과정코드가 유효한지 확인(테이블에 존재하는지 확인)
-- 2. 과정이 진행중인지 확인
-- 3. IF 과정 종료면 변경불가 오류 발생
--  IF 과정예정전 -> 변경가능 -> IF V_CLASSROOM이 이용중이면 -> 오류발생 
--  IF 강의중 -> IF 시작일이 V_시작일이 다르면 오류발생 -> 종료일만 수정 가능합니다
CREATE OR REPLACE PROCEDURE PRC_COURSE_UPDATE
(
     V_COUR_CODE     IN TBL_COURSE.COUR_CODE%TYPE      
,    V_CLASS_CODE    IN TBL_COURSE.CLASS_CODE%TYPE
,    V_STARTDATE     IN TBL_COURSE.STARTDATE%TYPE
,    V_ENDDATE       IN TBL_COURSE.ENDDATE%TYPE
,    V_LIMIT         IN TBL_COURSE.LIMIT%TYPE
) 
IS

    V_SD        TBL_COURSE.STARTDATE%TYPE;
    V_ED        TBL_COURSE.ENDDATE%TYPE;
    CCOUNT      NUMBER; --입력한 과정이 테이블에 유효한지를 담을 변수 
    CCHECK      VARCHAR2(30); --입력한 과정의 진행상황 확인을 담을 변수 
    
    USER_DEFINE_ERROR EXCEPTION;
    USER_DEFINE_ERROR2 EXCEPTION;
    USER_DEFINE_ERROR3 EXCEPTION;
    USER_DEFINE_ERROR4 EXCEPTION;
    
    CURSOR CUR_SDED_SELECT  -- 변경하려는 CLASS_CODE 의 날짜들 담을 
    IS
    SELECT STARTDATE,ENDDATE
    FROM TBL_COURSE
    WHERE CLASS_CODE = V_CLASS_CODE;
    
    V_CC        TBL_COURSE.COUR_CODE%TYPE;
    
BEGIN
    
    --입력한 COUR_CODE가 유효한지 확인
    SELECT COUNT(*) INTO CCOUNT
    FROM TBL_COURSE
    WHERE COUR_CODE = V_COUR_CODE;
    
    IF(CCOUNT = 0) -- 없으면 에러
        THEN RAISE USER_DEFINE_ERROR;
    END IF;
    
    --입력한 COUR_CODE의 진행상황 확인
    SELECT FN_COURSE(COUR_CODE) INTO CCHECK
    FROM TBL_COURSE
    WHERE COUR_CODE = V_COUR_CODE;
    
    IF(CCHECK = '과정 종료') --이미 종료된 과정이면 수정 불가 
        THEN RAISE USER_DEFINE_ERROR2;
    END IF;
    
    SELECT STARTDATE,ENDDATE INTO V_SD,V_ED
    FROM TBL_COURSE
    WHERE COUR_CODE = V_COUR_CODE;
    
    IF(CCHECK = '진행 중')
        THEN
             IF(V_STARTDATE != V_SD) --진행중인 과정은 시작날짜를 바꾸지 못함 
             THEN RAISE USER_DEFINE_ERROR3;
             END IF;
    END IF;
    
    
     OPEN CUR_SDED_SELECT;
        LOOP
            
            FETCH CUR_SDED_SELECT INTO V_SD,V_ED; --강의실이 똑같은 과정의 날짜 뽑아냄 
            
            SELECT COUR_CODE INTO V_CC
            FROM TBL_COURSE
            WHERE STARTDATE= V_SD AND ENDDATE =V_ED;
            
            IF(V_COUR_CODE != V_CC AND 
              ((V_SD <= V_STARTDATE AND V_STARTDATE <= V_ED) OR
               (V_SD <= V_ENDDATE AND V_ENDDATE <= V_ED) OR
                (V_STARTDATE <= V_SD AND V_ENDDATE > V_ED)))
                THEN RAISE USER_DEFINE_ERROR4;
            END IF;
            
            EXIT WHEN CUR_SDED_SELECT%NOTFOUND;
        END LOOP;

    CLOSE CUR_SDED_SELECT;
    
    --수정
    UPDATE TBL_COURSE
    SET COUR_CODE = V_COUR_CODE, CLASS_CODE = V_CLASS_CODE
    , STARTDATE = V_STARTDATE, ENDDATE = V_ENDDATE, LIMIT = V_LIMIT
    WHERE COUR_CODE = V_COUR_CODE;
   
   --예외처리
    EXCEPTION
        WHEN USER_DEFINE_ERROR
            THEN RAISE_APPLICATION_ERROR(-20015,'존재하지 않는 과정코드 입니다!'); 
                 ROLLBACK;
        WHEN USER_DEFINE_ERROR2
            THEN RAISE_APPLICATION_ERROR(-20016,'종료된 과정은 수정 불가합니다!');
                 ROLLBACK;
        WHEN USER_DEFINE_ERROR3
            THEN RAISE_APPLICATION_ERROR(-20017,'이미 진행중인 과정은 시작날짜를 변경할 수 없습니다');
                 ROLLBACK;
        WHEN USER_DEFINE_ERROR4
            THEN RAISE_APPLICATION_ERROR(-20006,'입력하신 강의실은 해당기간에 사용 불가합니다!');
                 ROLLBACK;
COMMIT;

END;


EXEC PRC_COURSE_UPDATE('빅데이터B',2, TO_DATE('2021-09-26','YYYY-MM-DD'), TO_DATE('2021-12-31','YYYY-MM-DD'),15);

EXEC PRC_COURSE_UPDATE('개발자A',2, TO_DATE('2021-08-01','YYYY-MM-DD'), TO_DATE('2021-10-31','YYYY-MM-DD'),15);



--=======================================================================================================

--■■■ 수강신청 테이블  

-- 수강신청 입력 프로시저
-- 수강신청이 이루어지면, 학생이 수강하는 과목에 대해 성적 테이블에 동시에 데이터 입력
CREATE OR REPLACE PROCEDURE PRC_REGIST_INSERT
( V_STU_ID      IN TBL_REGIST.STU_ID%TYPE
, V_COUR_CODE   IN TBL_REGIST.COUR_CODE%TYPE
)
IS
    USER_DEFINE_ERROR1   EXCEPTION;
    USER_DEFINE_ERROR2   EXCEPTION;
    USER_DEFINE_ERROR3   EXCEPTION;
    V_REG_CODE          TBL_REGIST.REG_CODE%TYPE;
    
    V2_STU_ID           TBL_REGIST.STU_ID%TYPE;
    V2_COUR_CODE        TBL_REGIST.COUR_CODE%TYPE;
    V_STARTDATE         TBL_COURSE.STARTDATE%TYPE;
    
    --TBL_GRADE 추가를 위한 변수선언
    CURSOR CUR_OPSUB_SELECT  --해당 과정에 해당하는 과목들 뽑아낼 커서 
    IS
    SELECT OPSUB_CODE
    FROM TBL_OPSUBJECT
    WHERE COUR_CODE = V_COUR_CODE;
    
    V_OPSUB_CODE        TBL_OPSUBJECT.OPSUB_CODE%TYPE; --뽑아낸 과목 담아낼 변수 
    V_GRADE_CODE        TBL_GRADE.GRADE_CODE%TYPE; 
    V_LIMIT             TBL_COURSE.LIMIT%TYPE;
    V_LIMIT_NOW         TBL_COURSE.LIMIT%TYPE;
    
BEGIN
    -- 수강신청 코드 자동증가 위한 조회
    SELECT NVL(MAX(REG_CODE),0) INTO V_REG_CODE
    FROM TBL_REGIST;
    
    -- 학생 ID 존재 여부 조회
    SELECT (
        SELECT STU_ID
        FROM TBL_STUDENT
        WHERE STU_ID = V_STU_ID) INTO V2_STU_ID
    FROM DUAL;
    
    -- 학생 없으면 예외발생
    IF (V2_STU_ID IS NULL)
        THEN RAISE USER_DEFINE_ERROR1;      
    END IF;
    
    -- 과정 존재 여부 조회
    SELECT (
        SELECT COUR_CODE
        FROM TBL_COURSE
        WHERE COUR_CODE = V_COUR_CODE) INTO V2_COUR_CODE
    FROM DUAL;
       
    -- 해당 과정 없으면 예외 발생
    IF (V2_COUR_CODE IS NULL)
        THEN RAISE USER_DEFINE_ERROR1;      
    END IF;
    
    -- 신청하려는 과정의 시작 날짜 조회
    SELECT STARTDATE INTO V_STARTDATE
    FROM TBL_COURSE
    WHERE COUR_CODE = V2_COUR_CODE;
    
    -- 이미 시작된 과정 신청 시 예외 발생
    IF (V_STARTDATE < SYSDATE)
        THEN RAISE USER_DEFINE_ERROR2;
    END IF;
    
    -- 수강인원이 제한인원보다 많을 경우 예외 발생
    SELECT COUNT(*) INTO V_LIMIT_NOW    -- 현재 이 과정을 수강하는 학생 인원수 
    FROM TBL_REGIST
    WHERE COUR_CODE = V_COUR_CODE;
    
    SELECT LIMIT INTO V_LIMIT       -- 과정의 정원
    FROM TBL_COURSE
    WHERE COUR_CODE = V_COUR_CODE;
    
    IF (V_LIMIT_NOW = V_LIMIT )     -- 현재 인원이 정원과 똑같다면, 이제 더 이상 인원추가가 안되니까 예외 발생
        THEN RAISE USER_DEFINE_ERROR3;
    END IF;
    
    -- 수강신청 테이블에 데이터 입력
    INSERT INTO TBL_REGIST (REG_CODE, STU_ID, COUR_CODE, REG_DATE)
        VALUES (V_REG_CODE+1, V_STU_ID, V_COUR_CODE, SYSDATE);          
               
    -- 수강신청이 이루어지고 난 후에 성적 테이블에 데이터입력을 위해 변수에 담기.
    SELECT REG_CODE INTO V_REG_CODE
    FROM TBL_REGIST
    WHERE STU_ID = V_STU_ID 
    AND COUR_CODE = V_COUR_CODE;
    
    --성적 테이블에 INSERT 
    OPEN CUR_OPSUB_SELECT;
    
    LOOP
        
        FETCH CUR_OPSUB_SELECT INTO V_OPSUB_CODE; 
            SELECT NVL(MAX(GRADE_CODE),0) INTO V_GRADE_CODE
            FROM TBL_GRADE; 
        EXIT WHEN CUR_OPSUB_SELECT%NOTFOUND;
            INSERT INTO TBL_GRADE(GRADE_CODE,OPSUB_CODE,REG_CODE)
            VALUES (V_GRADE_CODE +1, V_OPSUB_CODE, V_REG_CODE); 
        
    END LOOP;
    
    CLOSE CUR_OPSUB_SELECT;
    
    COMMIT; 
    
    
    EXCEPTION
        WHEN USER_DEFINE_ERROR1
            THEN RAISE_APPLICATION_ERROR(-20015,'학생 혹은 과정이 존재하지 않습니다.');
            ROLLBACK;
        WHEN USER_DEFINE_ERROR2
            THEN RAISE_APPLICATION_ERROR(-20016,'이미 개강된 과정입니다.');
            ROLLBACK;
        WHEN USER_DEFINE_ERROR3
            THEN RAISE_APPLICATION_ERROR(-20021,'수강인원이 초과됐습니다.');
            ROLLBACK;
    
END;


EXEC PRC_REGIST_INSERT('201402013', '개발자A');

--=======================================================================================================

--■■■ 중도하차여부 테이블

--중도하차 입력 프로시저
CREATE OR REPLACE PROCEDURE PRC_QUIT_INSERT
( V_REG_CODE    IN TBL_QUIT.REG_CODE%TYPE
, V_REASON      IN TBL_QUIT.REASON%TYPE
, V_QUIT_DATE   IN TBL_QUIT.QUIT_DATE%TYPE
)
IS
    V_QUIT_CODE TBL_QUIT.QUIT_CODE%TYPE;
    V_REG_CODE2 TBL_QUIT.REG_CODE%TYPE;
    V_REG_DATE  TBL_REGIST.REG_DATE%TYPE;
    V_STARTDATE TBL_COURSE.STARTDATE%TYPE;
    V_ENDDATE   TBL_COURSE.ENDDATE%TYPE;
    
    USER_DEFINE_ERROR  EXCEPTION;
    USER_DEFINE_ERROR2 EXCEPTION;
BEGIN
    -- 수강신청코드가 존재하지 않을경우
    SELECT REG_CODE, REG_DATE INTO V_REG_CODE2, V_REG_DATE
    FROM TBL_REGIST
    WHERE REG_CODE = V_REG_CODE;
    
    -- 과정시작일 과정종료일
    SELECT STARTDATE, ENDDATE INTO V_STARTDATE,V_ENDDATE
    FROM TBL_COURSE
    WHERE COUR_CODE = (SELECT COUR_CODE
                       FROM TBL_REGIST
                       WHERE REG_CODE = V_REG_CODE);

    SELECT NVL(MAX(QUIT_CODE),0) INTO V_QUIT_CODE
    FROM TBL_QUIT;
    
    -- 하차일자가 수강신청날짜보다 이전일 경우 에러
    IF (V_QUIT_DATE < V_REG_DATE)
        THEN RAISE USER_DEFINE_ERROR;
    END IF;
    
    -- 하차일자가 과정시작일보다 이전이거나 과정종료 이후일 경우 에러
    IF ((V_QUIT_DATE < V_STARTDATE) OR V_QUIT_DATE > V_ENDDATE)
        THEN RAISE USER_DEFINE_ERROR2;
    END IF;    
    
    INSERT INTO TBL_QUIT(QUIT_CODE, REG_CODE, REASON, QUIT_DATE)
    VALUES (V_QUIT_CODE +1, V_REG_CODE, V_REASON, V_QUIT_DATE);
    
    --COMMIT; 
    EXCEPTION
        
        -- 하차일자가 수강신청날짜보다 이전일 경우
        WHEN USER_DEFINE_ERROR
            THEN RAISE_APPLICATION_ERROR(-20009,'하차일자가 수강신청 날짜보다 이전입니다.');
            ROLLBACK;
        
        -- 하차일자가 과정시작일보다 이전이거나 과정종료 이후일 경우 에러
        WHEN USER_DEFINE_ERROR2
            THEN RAISE_APPLICATION_ERROR(-20010,'하차일자가 과정시작일 이전이거나 과정종료일 이후입니다.');
            ROLLBACK;
        
        -- 수강신청테이블에 수강신청코드 존재 X    
        WHEN NO_DATA_FOUND
            THEN RAISE_APPLICATION_ERROR(-20017,'수강신청코드가 존재하지 않습니다.');
            ROLLBACK;
            
END;

EXEC PRC_QUIT_INSERT(3, '오라클어려워요', TO_DATE('2021-10-01', 'YYYY-MM-DD'));

------------------------------------------------------------------------

--중도하차 이유, 날짜 수정 프로시저
CREATE OR REPLACE PROCEDURE PRC_QUIT_UPDATE
( V_QUIT_CODE   IN TBL_QUIT.QUIT_CODE%TYPE
, V_REASON      IN TBL_QUIT.REASON%TYPE
, V_QUIT_DATE   IN TBL_QUIT.QUIT_DATE%TYPE
)
IS
    V_REG_CODE  TBL_QUIT.REG_CODE%TYPE;
    V_REG_DATE  TBL_REGIST.REG_DATE%TYPE;
    V_COUR_CODE TBL_COURSE.COUR_CODE%TYPE;
    V_STARTDATE TBL_COURSE.STARTDATE%TYPE;
    V_ENDDATE   TBL_COURSE.ENDDATE%TYPE;
    
    USER_DEFINE_ERROR  EXCEPTION;
    USER_DEFINE_ERROR2 EXCEPTION;
BEGIN
    -- 수강신청일, 과정코드
    SELECT REG_DATE, COUR_CODE INTO V_REG_DATE, V_COUR_CODE
    FROM TBL_REGIST
    WHERE REG_CODE = (SELECT REG_CODE
                      FROM TBL_QUIT
                      WHERE QUIT_CODE = V_QUIT_CODE);
    
    -- 과정시작일, 종료일
    SELECT STARTDATE, ENDDATE INTO V_STARTDATE, V_ENDDATE 
    FROM TBL_COURSE
    WHERE COUR_CODE = V_COUR_CODE;

    -- 하차일자가 수강신청 날짜보다 이전일경우 에러
    IF (V_QUIT_DATE < V_REG_DATE)
        THEN RAISE USER_DEFINE_ERROR;
    END IF;
    
    -- 하차일자가 과정시작일보다 이전이거나 과정종료 이후일 경우 에러
    IF ((V_QUIT_DATE < V_STARTDATE) OR (V_QUIT_DATE > V_ENDDATE))
        THEN RAISE USER_DEFINE_ERROR2;
    END IF;

    --UPDATE 쿼리문
    UPDATE TBL_QUIT
    SET REASON = V_REASON, QUIT_DATE = V_QUIT_DATE
    WHERE QUIT_CODE = V_QUIT_CODE;
    
    --COMMIT; 
    
    EXCEPTION
        WHEN USER_DEFINE_ERROR
            THEN RAISE_APPLICATION_ERROR(-20009,'하차일자가 수강신청 날짜보다 이전입니다.');
            ROLLBACK;
        WHEN USER_DEFINE_ERROR2
            THEN RAISE_APPLICATION_ERROR(-20010,'하차일자가 과정시작일 이전이거나 과정종료일 이후입니다.');
            ROLLBACK;
        WHEN OTHERS
            THEN ROLLBACK;
END;


EXEC PRC_QUIT_UPDATE(1, '당장 그만둘꺼임', TO_DATE('2021-12-29', 'YYYY-MM-DD'));


--=======================================================================================================

--■■■ 개설과목 테이블  

--○ 개설과목 INSERT 프로시저
-- 과목의 기간은 과정 안에 포함 되어야함
-- 교수가 이미 다른 과목 강의중이면 에러 

CREATE OR REPLACE PROCEDURE PRC_OPSUBJECT_INSERT
( V_COUR_CODE      IN TBL_OPSUBJECT.COUR_CODE%TYPE
, V_SUB_CODE       IN TBL_OPSUBJECT.SUB_CODE%TYPE
, V_PRO_ID         IN TBL_OPSUBJECT.PRO_ID%TYPE
, V_ALLOT_CODE     IN TBL_OPSUBJECT.ALLOT_CODE%TYPE
, V_STARTDATE      IN TBL_OPSUBJECT.STARTDATE%TYPE
, V_ENDDATE        IN TBL_OPSUBJECT.ENDDATE%TYPE
)
IS
    V_OPSUB_CODE        TBL_OPSUBJECT.OPSUB_CODE%TYPE; --개설과목 코드 
    V_COUR_STARTDATE    TBL_COURSE.STARTDATE%TYPE; --과정의 시작일
    V_COUR_ENDDATE      TBL_COURSE.ENDDATE%TYPE;   --과정의 종료일
    USER_DEFINE_ERROR   EXCEPTION;
    USER_DEFINE_ERROR2   EXCEPTION;
    
    CURSOR CUR_SDED_SELECT 
    IS
    SELECT STARTDATE,ENDDATE
    FROM TBL_OPSUBJECT
    WHERE PRO_ID = V_PRO_ID;
    
    V_SD        TBL_OPSUBJECT.STARTDATE%TYPE; --커서에 담을 변수들 
    V_ED        TBL_OPSUBJECT.ENDDATE%TYPE;
    
    
BEGIN

    SELECT NVL(MAX(OPSUB_CODE),0) INTO V_OPSUB_CODE
    FROM TBL_OPSUBJECT;
    
    SELECT STARTDATE,ENDDATE INTO V_COUR_STARTDATE,V_COUR_ENDDATE
    FROM TBL_COURSE
    WHERE COUR_CODE = V_COUR_CODE;
    
    --과목 날짜는 과정 안에 포함되어야 한다 -> 아닐 시 에러 
    IF( (V_STARTDATE < V_COUR_STARTDATE) OR (V_ENDDATE > V_COUR_ENDDATE)
       OR (V_STARTDATE > V_COUR_ENDDATE) )
        THEN RAISE USER_DEFINE_ERROR;
    END IF;
    
    --입력한 교수가 해당날짜에 이미 강의중이면 에러 
     OPEN CUR_SDED_SELECT;
        LOOP
            
            FETCH CUR_SDED_SELECT INTO V_SD,V_ED; --강의실이 똑같은 과정의 날짜 뽑아냄 
        
            IF( (V_SD <= V_STARTDATE AND V_STARTDATE <= V_ED) OR
               (V_SD <= V_ENDDATE AND V_ENDDATE <= V_ED) OR
                (V_STARTDATE <= V_SD AND V_ENDDATE > V_ED))
                THEN RAISE USER_DEFINE_ERROR2;
            END IF;
            
            EXIT WHEN CUR_SDED_SELECT%NOTFOUND;
        END LOOP;

    CLOSE CUR_SDED_SELECT;
    
    
    
    INSERT INTO TBL_OPSUBJECT(OPSUB_CODE,COUR_CODE,SUB_CODE,PRO_ID,ALLOT_CODE,STARTDATE,ENDDATE)
    VALUES (V_OPSUB_CODE +1 , V_COUR_CODE, V_SUB_CODE, V_PRO_ID, V_ALLOT_CODE,V_STARTDATE, V_ENDDATE);
     
   EXCEPTION
        WHEN USER_DEFINE_ERROR
            THEN RAISE_APPLICATION_ERROR(-20008,'과목의 수업기간은 과정 기간 내에 포함되어야 합니다!');
                 ROLLBACK;
        WHEN USER_DEFINE_ERROR2
                THEN RAISE_APPLICATION_ERROR(-20008,'입력하신 교수는 해당 날짜에 이미 강의중입니다!');
                     ROLLBACK;
    
    COMMIT;
END;


EXEC PRC_OPSUBJECT_INSERT('개발자A',2,'gmlee',1,TO_DATE('2021-01-01', 'YYYY-MM-DD'),TO_DATE('2021-01-15', 'YYYY-MM-DD'));
--==>> 확인 완료

------------------------------------------------------------------------

-- 개설과목 교수자 변경 프로시저
--○ 개설과목 UPDATE 프로시저 -> 관리자 -> 필요한 경우 담당 교수자 배정을 변경할 수 있다.
--과목코드, 교수명
--TBL_OPSUBJECT에서 입력받은 PRO_ID 인 개설과목들의 STARTDATE 와 ENDDATE를 뽑아낸다
--커서로 변수에 다 담고 
--입력받은 OPSUB_CODE에 해당하는 STARTDATE 와 ENDDATE를 뽑아낸다 
--비교한다    -> 겹치면 에러               
CREATE OR REPLACE PROCEDURE PRC_OPSUBJECT_UPDATE
( V_OPSUB_CODE        IN TBL_OPSUBJECT.OPSUB_CODE%TYPE --개설과목 코드 
 ,V_PRO_ID            IN TBL_OPSUBJECT.PRO_ID%TYPE --변경할 교수ID 매개변수 
)
IS
    
    RESULT            NUMBER; -- 매개변수로 받은 교수 id 가 존재하는지 여부 받을 변수 
    USER_DEFINE_ERROR   EXCEPTION;
    USER_DEFINE_ERROR2   EXCEPTION;
    
    V_STARTDATE     TBL_OPSUBJECT.STARTDATE%TYPE;
    V_ENDDATE       TBL_OPSUBJECT.ENDDATE%TYPE; --입력받은 개설과목의 해당 날짜담을 변수 
    
    CURSOR CUR_SDED_SELECT 
    IS
    SELECT STARTDATE,ENDDATE
    FROM TBL_OPSUBJECT
    WHERE PRO_ID = V_PRO_ID;
    
    V_SD        TBL_OPSUBJECT.STARTDATE%TYPE; --커서에 담을 변수들 
    V_ED        TBL_OPSUBJECT.ENDDATE%TYPE;
    
    
BEGIN
    
    --입력한 교수ID가 교수 테이블에 없으면...
    SELECT COUNT(*) INTO RESULT
    FROM TBL_PROFESSOR
    WHERE PRO_ID = V_PRO_ID;
    
    IF(RESULT = 0)
        THEN RAISE USER_DEFINE_ERROR;
    END IF;
    
    SELECT STARTDATE,ENDDATE INTO V_STARTDATE,V_ENDDATE
    FROM TBL_OPSUBJECT
    WHERE OPSUB_CODE = V_OPSUB_CODE;
    
     OPEN CUR_SDED_SELECT;
        LOOP
            
            FETCH CUR_SDED_SELECT INTO V_SD,V_ED; --강의실이 똑같은 과정의 날짜 뽑아냄 
        
            IF( (V_SD <= V_STARTDATE AND V_STARTDATE <= V_ED) OR
               (V_SD <= V_ENDDATE AND V_ENDDATE <= V_ED) OR
                (V_STARTDATE <= V_SD AND V_ENDDATE > V_ED))
                THEN RAISE USER_DEFINE_ERROR2;
            END IF;
            
            EXIT WHEN CUR_SDED_SELECT%NOTFOUND;
        END LOOP;

    CLOSE CUR_SDED_SELECT;
    
    
    --UPDATE 실행 
    UPDATE TBL_OPSUBJECT
    SET PRO_ID = V_PRO_ID
    WHERE OPSUB_CODE = V_OPSUB_CODE; 
    
    --COMMIT;
    
   EXCEPTION
        WHEN USER_DEFINE_ERROR
            THEN RAISE_APPLICATION_ERROR(-20007,'입력하신 교수ID가 존재하지 않습니다!');
                 ROLLBACK;
        WHEN USER_DEFINE_ERROR2
            THEN RAISE_APPLICATION_ERROR(-20008,'입력하신 교수는 해당 날짜에 이미 강의중입니다!');
                 ROLLBACK;
END;


EXEC PRC_OPSUBJECT_UPDATE(10013,'jhlim');
--==>> 확인 완료 

------------------------------------------------------------------------

--개설과목 배점 변경 프로시저
CREATE OR REPLACE PROCEDURE PRC_OPSUB_ALLOT_UPDATE
( V_PRO_ID            IN TBL_OPSUBJECT.PRO_ID%TYPE     --변경할 교수ID 
 ,V_OPSUB_CODE        IN TBL_OPSUBJECT.OPSUB_CODE%TYPE --개설과목 코드
 ,V_ALLOT_CODE        IN TBL_OPSUBJECT.ALLOT_CODE%TYPE --변경할 배점
)
IS
    RESULT            NUMBER;
    USER_DEFINE_ERROR   EXCEPTION;
    USER_DEFINE_ERROR2   EXCEPTION;
    
BEGIN
    
    --변경 하려는 교수 ID + 과목이 테이블에 잘 있는지 확인작업  
    SELECT COUNT(*) INTO RESULT
    FROM TBL_OPSUBJECT
    WHERE PRO_ID = V_PRO_ID AND OPSUB_CODE = V_OPSUB_CODE;
    
    IF(RESULT =0) --없으면 에러 
        THEN RAISE USER_DEFINE_ERROR;
    END IF;
    
    --받은 배점이 배점 테이블에 있는지 확인 
    SELECT COUNT(*) INTO RESULT  
    FROM TBL_ALLOT
    WHERE ALLOT_CODE = V_ALLOT_CODE;
    
    IF(RESULT =0) --없으면 에러 
        THEN RAISE USER_DEFINE_ERROR2;
    END IF;
    
    --UPDATE 실행 
    UPDATE TBL_OPSUBJECT
    SET ALLOT_CODE = V_ALLOT_CODE
    WHERE OPSUB_CODE = V_OPSUB_CODE; 
    
   EXCEPTION
        WHEN USER_DEFINE_ERROR
            THEN RAISE_APPLICATION_ERROR(-20018,'해당 교수와 과목이 유효하지 않습니다!');
                 ROLLBACK;
        WHEN USER_DEFINE_ERROR2
            THEN RAISE_APPLICATION_ERROR(-20019,'해당 배점 비율이 존재하지 않습니다!');
                 ROLLBACK;
END;

--프로시저 호출
EXEC PRC_OPSUB_ALLOT_UPDATE('jhlim', 10003, 1);

SELECT *
FROM TBL_ALLOT;
------------------------------------------------------------------------

--개설과목 삭제 => 그 해당 과정이 진행중이면 못 삭제 , 진행 전이면 다 삭제 
--과목을 삭제하면 해당 과목이 올라가있는 수강신청도 삭제해야함
--사용 예)  PRC_OPSUB_DELETE('개설과목 코드');
CREATE OR REPLACE PROCEDURE PRC_OPSUB_DELETE
(
    V_OPSUB_CODE    TBL_OPSUBJECT.OPSUB_CODE%TYPE
) 
IS 
    CCHECK         VARCHAR2(40); --과정 상태확인 변수 
    USER_DEFINE_ERROR   EXCEPTION;
    
BEGIN
    
    SELECT FN_COURSE(COUR_CODE) INTO CCHECK
    FROM TBL_OPSUBJECT
    WHERE OPSUB_CODE = V_OPSUB_CODE;
    
    IF(CCHECK = '진행중' OR CCHECK = '과정 종료')
        THEN RAISE USER_DEFINE_ERROR;
    END IF;
    
    --자식 삭제 과정
    DELETE
    FROM TBL_GRADE
    WHERE OPSUB_CODE = V_OPSUB_CODE;
     
    --과목삭제 
    DELETE
    FROM TBL_OPSUBJECT
    WHERE OPSUB_CODE = V_OPSUB_CODE;
    
    COMMIT;
    
    EXCEPTION
        WHEN USER_DEFINE_ERROR
            THEN RAISE_APPLICATION_ERROR(-20015,'개설된 과목은 삭제 불가합니다.');
            ROLLBACK;
            
END;


--프로시저 호출
EXEC PRC_OPSUB_DELETE('10003');


--=======================================================================================================

--■■■ 성적 테이블  

-- 성적 입력 프로시저(근데 수정임) 교수가 성적 입력하는.
CREATE OR REPLACE PROCEDURE PRC_GRADE_UPDATE
--매개변수 -> 수강신청코드, 점수3개
( V_GRADE_CODE   IN TBL_GRADE.GRADE_CODE%TYPE   
, V_ATTEND       IN TBL_GRADE.ATTEND%TYPE
, V_PRACTICE     IN TBL_GRADE.PRACTICE%TYPE
, V_WRITTEN      IN TBL_GRADE.WRITTEN%TYPE
)
IS
    RESULT  NUMBER;
    USER_DEFINE_ERROR   EXCEPTION;    
BEGIN
    --성적 테이블에서 성적코드가 존재하는지 조회
    SELECT COUNT(*) INTO RESULT  
    FROM TBL_GRADE
    WHERE GRADE_CODE = V_GRADE_CODE;
    
    IF(RESULT =0) --없으면 에러 
        THEN RAISE USER_DEFINE_ERROR;
    END IF;
    
    -- UPDATE 쿼리문 구성 -> 성적테이블에서 
    UPDATE TBL_GRADE
    SET ATTEND =V_ATTEND , WRITTEN = V_WRITTEN , PRACTICE = V_PRACTICE
    WHERE GRADE_CODE = V_GRADE_CODE; 
    
    EXCEPTION
        WHEN USER_DEFINE_ERROR
            THEN RAISE_APPLICATION_ERROR(-20020,'성적코드가 유효하지 않습니다.');
                 ROLLBACK;
    COMMIT;
END;

-- 프로시저 사용 구문
EXEC PRC_GRADE_UPDATE(1, 100, 80, 90);


--=======================================================================================================

COMMIT;