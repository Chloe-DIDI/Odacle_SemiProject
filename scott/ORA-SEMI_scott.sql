

-- TBL_CLASSROOM ����
CREATE TABLE TBL_CLASSROOM
( CLASS_CODE  NUMBER      
, NAME        VARCHAR2(20) CONSTRAINT CLASSROOM_NAME_NN NOT NULL
, CAPACITY    VARCHAR2(30)
, CONSTRAINT CLASSROOM_CLASS_CODE_PK PRIMARY KEY(CLASS_CODE)
);

-- TBL_ALLOT ����
CREATE TABLE TBL_ALLOT
( ALLOT_CODE    NUMBER    
, ATTEND        NUMBER(3) DEFAULT 0
, PRACTICE      NUMBER(3) DEFAULT 0
, WRITTEN       NUMBER(3) DEFAULT 0
, CONSTRAINT ALLOT_ALLOT_CODE_PK PRIMARY KEY(ALLOT_CODE)
);


������, ���� ����..

-- ���� ������ ���̺� ���� (TBL_ADMIN) ���� --
CREATE TABLE TBL_ADMIN
( ADMIN_ID  VARCHAR2(20)                                            --������ ���̵�(PK)
, PW        VARCHAR2(20)    CONSTRAINT ADMIN_PW_NN NOT NULL         --������ �н�����(NN)
, NAME      VARCHAR2(20)    CONSTRAINT ADMIN_NAME_NN NOT NULL       --������ �̸�
, CONSTRAINT ADMIN_ADMIN_ID_PK PRIMARY KEY(ADMIN_ID)
);

��
INSERT INTO TBL_ADMIN(ADMIN_ID, PW, NAME) VALUES ('hohohaha', '1111', '��ȣ��');
INSERT INTO TBL_ADMIN(ADMIN_ID, PW, NAME) VALUES ('captainme', '1010', '���쵿');

-- ���� ���� ���̺� ���� (TBL_SUBJECTS) ���� --
CREATE TABLE TBL_SUBJECTS
( SUB_CODE  NUMBER                                                  --�����ڵ�(PK)
, NAME      VARCHAR2(20)    CONSTRAINT SUBJECTS_NAME_NN NOT NULL    --�����(NN)
, BOOK      VARCHAR2(20)                                            --�����
, CONSTRAINT SUBJECTS_SUB_CODE_PK PRIMARY KEY(SUB_CODE)
);
��

INSERT INTO TBL_SUBJECTS(SUB_CODE, NAME, BOOK) VALUES (001, '�ڹ�', '�̰��� �ڹٴ�');
INSERT INTO TBL_SUBJECTS(SUB_CODE, NAME, BOOK) VALUES (001, '�ڹ�', 'JAVA�� ����');
INSERT INTO TBL_SUBJECTS(SUB_CODE, NAME, BOOK) VALUES (002, '����Ŭ', '����Ŭ SQL�� PL/SQL');
INSERT INTO TBL_SUBJECTS(SUB_CODE, NAME, BOOK) VALUES (003, '���̽�', '�̰��� ����� ���� �ڵ� �׽�Ʈ�� with ���̽�');
INSERT INTO TBL_SUBJECTS(SUB_CODE, NAME, BOOK) VALUES (004, 'C ���', '���ϰ� �����ϴ� C ���α׷���');
INSERT INTO TBL_SUBJECTS(SUB_CODE, NAME, BOOK) VALUES (005, '������', '������ �� ��ŸƮ');




--------------------- �ٸ� ������ ����------------------------------------------
--�� ���� ���̺� ���� 
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

-- ���� ������ ���̺� ���� (TBL_ADMIN) ���� --
CREATE TABLE TBL_ADMIN
( ADMIN_ID  VARCHAR2(20)                                            --������ ���̵�(PK)
, PW        VARCHAR2(20)    CONSTRAINT ADMIN_PW_NN NOT NULL         --������ �н�����(NN)
, NAME      VARCHAR2(20)    CONSTRAINT ADMIN_NAME_NN NOT NULL       --������ �̸�
, CONSTRAINT ADMIN_ID_PK PRIMARY KEY(ADMIN_ID)
);


--------------------------------------------------------------------------------
-------------�տ� ��� ���� �����ͼ� �ϴ� ��------------------------------------
----------------------�� ���̺� ���� ��-----------------------------------------
DROP TABLE TBL_ALLOT;


-- JOBS ���̺� ����
CREATE TABLE JOBS02
(
    JOB_ID      VARCHAR2(10)
,   JOB_TITLE   VARCHAR2(35) CONSTRAINT JOB02_TITLE_NN NOT NULL
,   MIN_SALARY  NUMBER(6)            --���̺��_�̸�_NN NOT NULL
,   MAX_SALARY  NUMBER(6)
,   CONSTRAINT  JOB02_ID_PK PRIMARY KEY(JOB_ID)  
);





---------------------�۵����� �Է¡�---------------------------
INSERT INTO TBL_BOARD(SID, NAME, CONTENTS, WRITEDAY, COMMENTS, COUNTS)
VALUES(SEQ_BOARD.NEXTVAL, '������', '��� �׽�Ʈ���Դϴ�.', SYSDATE, 0, 0);
--==>> 1 �� ��(��) ���ԵǾ����ϴ�.

INSERT INTO TBL_BOARD(SID, NAME, CONTENTS, WRITEDAY, COMMENTS, COUNTS)
VALUES(SEQ_BOARD.NEXTVAL, 'ä����', '���� �׽�Ʈ���Դϴ�.', DEFAULT, DEFAULT, DEFAULT);