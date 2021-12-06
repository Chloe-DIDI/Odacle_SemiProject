

-- TBL_CLASSROOM 생성
CREATE TABLE TBL_CLASSROOM
( CLASS_CODE  NUMBER      
, NAME        VARCHAR2(20) CONSTRAINT CLASSROOM_NAME_NN NOT NULL
, CAPACITY    VARCHAR2(30)
, CONSTRAINT CLASSROOM_CLASS_CODE_PK PRIMARY KEY(CLASS_CODE)
);

-- TBL_ALLOT 생성
CREATE TABLE TBL_ALLOT
( ALLOT_CODE    NUMBER    
, ATTEND        NUMBER(3) DEFAULT 0
, PRACTICE      NUMBER(3) DEFAULT 0
, WRITTEN       NUMBER(3) DEFAULT 0
, CONSTRAINT ALLOT_ALLOT_CODE_PK PRIMARY KEY(ALLOT_CODE)
);


관리자, 과목 내가..

-- ■■■ 관리자 테이블 생성 (TBL_ADMIN) ■■■ --
CREATE TABLE TBL_ADMIN
( ADMIN_ID  VARCHAR2(20)                                            --관리자 아이디(PK)
, PW        VARCHAR2(20)    CONSTRAINT ADMIN_PW_NN NOT NULL         --관리자 패스워드(NN)
, NAME      VARCHAR2(20)    CONSTRAINT ADMIN_NAME_NN NOT NULL       --관리자 이름
, CONSTRAINT ADMIN_ADMIN_ID_PK PRIMARY KEY(ADMIN_ID)
);

★
INSERT INTO TBL_ADMIN(ADMIN_ID, PW, NAME) VALUES ('hohohaha', '1111', '김호진');
INSERT INTO TBL_ADMIN(ADMIN_ID, PW, NAME) VALUES ('captainme', '1010', '윤우동');

-- ■■■ 과목 테이블 생성 (TBL_SUBJECTS) ■■■ --
CREATE TABLE TBL_SUBJECTS
( SUB_CODE  NUMBER                                                  --과목코드(PK)
, NAME      VARCHAR2(20)    CONSTRAINT SUBJECTS_NAME_NN NOT NULL    --과목명(NN)
, BOOK      VARCHAR2(20)                                            --교재명
, CONSTRAINT SUBJECTS_SUB_CODE_PK PRIMARY KEY(SUB_CODE)
);
★

INSERT INTO TBL_SUBJECTS(SUB_CODE, NAME, BOOK) VALUES (001, '자바', '이것이 자바다');
INSERT INTO TBL_SUBJECTS(SUB_CODE, NAME, BOOK) VALUES (001, '자바', 'JAVA의 정석');
INSERT INTO TBL_SUBJECTS(SUB_CODE, NAME, BOOK) VALUES (002, '오라클', '오라클 SQL과 PL/SQL');
INSERT INTO TBL_SUBJECTS(SUB_CODE, NAME, BOOK) VALUES (003, '파이썬', '이것이 취업을 위한 코딩 테스트다 with 파이썬');
INSERT INTO TBL_SUBJECTS(SUB_CODE, NAME, BOOK) VALUES (004, 'C 언어', '독하게 시작하는 C 프로그래밍');
INSERT INTO TBL_SUBJECTS(SUB_CODE, NAME, BOOK) VALUES (005, '스프링', '스프링 퀵 스타트');




--------------------- 다른 조원꺼 참조------------------------------------------
--○ 교수 테이블 생성 
CREATE TABLE TBL_PROFESSOR
( PRO_ID    VARCHAR2(20)
 ,PW        VARCHAR2(20) DEFAULT BSSN
 ,NAME      VARCHAR2(20) CONSTRAINT PROFESSOR_NAME_NN NOT NULL 
 ,FSSN      CHAR(6) CONSTRAINT PROFESSOR_FSSN_NN NOT NULL
 ,BSSN      CHAR(7) CONSTRAINT PROFESSOR_BSSN_NN NOT NULL 
 ,SIGNDATE  DATE DEFAULT SYSDATE
 ,CONSTRAINT PROFESSOR_PRO_ID_PK PRIMARY KEY(PRO_ID)
);

CREATE TABLE TBL_STUDENT
( STU_ID   VARCHAR2(20)
, PW          VARCHAR2(20)  DEFAULT BSSN
, NAME       VARCHAR2(20)  CONSTRAINT STUDENT_NAME_NN NOT NULL
, FSSN        CHAR(6)        CONSTRAINT STUDENT_FSSN_NN NOT NULL
, BSSN        CHAR(7)        CONSTRAINT STUDENT_BSSN_NN NOT NULL
, SIGNDATE    DATE DEFAULT SYSDATE
, CONSTRAINT STUDENT_STU_ID_PK PRIMARY KEY (STU_ID)
);

-- ■■■ 관리자 테이블 생성 (TBL_ADMIN) ■■■ --
CREATE TABLE TBL_ADMIN
( ADMIN_ID  VARCHAR2(20)                                            --관리자 아이디(PK)
, PW        VARCHAR2(20)    CONSTRAINT ADMIN_PW_NN NOT NULL         --관리자 패스워드(NN)
, NAME      VARCHAR2(20)    CONSTRAINT ADMIN_NAME_NN NOT NULL       --관리자 이름
, CONSTRAINT ADMIN_ID_PK PRIMARY KEY(ADMIN_ID)
);


--------------------------------------------------------------------------------
-------------앞에 배운 내용 데려와서 하는 것------------------------------------
----------------------○ 테이블 생성 ○-----------------------------------------
DROP TABLE TBL_ALLOT;


-- JOBS 테이블 생성
CREATE TABLE JOBS02
(
    JOB_ID      VARCHAR2(10)
,   JOB_TITLE   VARCHAR2(35) CONSTRAINT JOB02_TITLE_NN NOT NULL
,   MIN_SALARY  NUMBER(6)            --테이블명_이름_NN NOT NULL
,   MAX_SALARY  NUMBER(6)
,   CONSTRAINT  JOB02_ID_PK PRIMARY KEY(JOB_ID)  
);





---------------------○데이터 입력○---------------------------
INSERT INTO TBL_BOARD(SID, NAME, CONTENTS, WRITEDAY, COMMENTS, COUNTS)
VALUES(SEQ_BOARD.NEXTVAL, '윤유동', '계속 테스트중입니다.', SYSDATE, 0, 0);
--==>> 1 행 이(가) 삽입되었습니다.

INSERT INTO TBL_BOARD(SID, NAME, CONTENTS, WRITEDAY, COMMENTS, COUNTS)
VALUES(SEQ_BOARD.NEXTVAL, '채지윤', '힘껏 테스트중입니다.', DEFAULT, DEFAULT, DEFAULT);