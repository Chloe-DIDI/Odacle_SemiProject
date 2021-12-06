--------------------------------------------------------------------
--�� �����ڰ� ����л����� ��� �������� ���� 
-- �л���, ������, ��������, �������, �Ǳ�����, �ʱ�����, ����, �ߵ���������
--------------------------------------------------------------------
CREATE OR REPLACE VIEW VIEW_STUDENT_INFO
AS
SELECT T1.�л���, T1.������, T1.��������, T1.�������, T1.�Ǳ�����, T1.�ʱ�����
     , (T1.������� + T1.�Ǳ����� + T1.�ʱ�����) "����", T1.�ߵ���������
FROM
(
    SELECT ST.NAME"�л���",CO.COUR_CODE"������" 
        , SU.NAME "��������"
        , FN_SCORE_ATTEND(GR.GRADE_CODE) "�������"
        , FN_SCORE_PRACTICE(GR.GRADE_CODE) "�Ǳ�����"
        , FN_SCORE_WRITTEN(GR.GRADE_CODE) "�ʱ�����"
        , FN_QUIT(RE.REG_CODE) "�ߵ���������"
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
)T1;

--��ȸ
SELECT *   
FROM VIEW_STUDENT_INFO;




----------------------------------------------------------------
--�� ������) ���� ���� ��ȸ VIEW ���� (VIEW_OPSUBJECT)
-- ��� ������ ���� ��ȸ
-- ��� : ������, ���ǽ�, �����, ����SDATE, ����EDATE, ����, ������
-- ��������(������), ���ǽ�(���ǽ��̸�), ��������(�����), ��������(������,����)
-- , ����(�����), ����(������)
----------------------------------------------------------------
CREATE OR REPLACE VIEW VIEW_OPSUBJECT
AS
SELECT O.COUR_CODE "������", CR.NAME "���ǽ�", S.NAME "�����"
    , O.STARTDATE "���������", O.ENDDATE "����������", S.BOOK "�����", P.NAME "������"
FROM TBL_OPSUBJECT O LEFT JOIN TBL_SUBJECTS S
ON O.SUB_CODE = S.SUB_CODE
    LEFT JOIN TBL_PROFESSOR P
    ON O.PRO_ID = P. PRO_ID
    LEFT JOIN TBL_COURSE C
    ON O.COUR_CODE = C.COUR_CODE
    LEFT JOIN TBL_CLASSROOM CR
    ON C.CLASS_CODE = CR.CLASS_CODE;
    

--��ȸ
SELECT * FROM VIEW_OPSUBJECT;


----------------------------------------------------------------
--�� �����ڰ� ���� ���� ��ȸ �ϴ� VIEW ���� (VIEW_PROFESSOR_COUR)

-- ������ ���� ��ȸ (��� �����ڿ� ���� ���� ���)
-- ������, ��������, ����SDATE, ����EDATE, �����, ���ǽ�, ���� ���� ����
-- ����, ����, ��������, ����, ���ǽ�
-- ���� ���� ���� (FN_LECTUR) �Լ� ���
----------------------------------------------------------------
CREATE OR REPLACE VIEW VIEW_PROFESSOR_COUR
AS
SELECT P.NAME "������", O.COUR_CODE "��������", O.STARTDATE "���������", O.ENDDATE "����������"
     , S.BOOK "�����", R.NAME "���ǽ�", FN_COURSE(C.COUR_CODE) "�������࿩��"
FROM TBL_PROFESSOR P LEFT JOIN TBL_OPSUBJECT O
ON P.PRO_ID = O.PRO_ID
    LEFT JOIN TBL_SUBJECTS S
    ON O.SUB_CODE = S.SUB_CODE
    LEFT JOIN TBL_COURSE C
    ON O.COUR_CODE = C.COUR_CODE
    LEFT JOIN TBL_CLASSROOM R
    ON C.CLASS_CODE = R.CLASS_CODE;


-- ��ȸ    
SELECT * FROM VIEW_PROFESSOR_COUR;



----------------------------------------
--�� �����ڰ� ������ ���� ��ȸ �ϴ� VIEW ���� (VIEW_PROFESSOR_COUR)
-- ���� ���� �� ���� 
----------------------------------------
CREATE OR REPLACE VIEW VIEW_COURSE
AS
SELECT CO.COUR_CODE"������", CL.CAPACITY "���ǽ�" , SU.NAME"�����"
     , CO.STARTDATE"������",CO.ENDDATE"������", SU.BOOK"�����̸�", PRO.NAME"�����ڸ�"     
     , FN_COURSE(CO.COUR_CODE)"�������࿩��"
FROM TBL_PROFESSOR PRO RIGHT JOIN TBL_OPSUBJECT OP
ON PRO.PRO_ID = OP.PRO_ID
    LEFT JOIN TBL_SUBJECTS SU ON OP.SUB_CODE = SU.SUB_CODE
    RIGHT JOIN TBL_COURSE CO ON CO.COUR_CODE = OP.COUR_CODE
    LEFT JOIN TBL_CLASSROOM CL ON CL.CLASS_CODE = CO.CLASS_CODE;
 
-- 
SELECT * FROM VIEW_COURSE;    


---------------------------------
--�� ������ ���� �� ���� 
----------------------------------
-- ������ ���� ���� ��ȸ
-- �����, ���� SDATE, ����EDATE, �����̸�, �л��̸�, ���, �Ǳ�, �ʱ�, ����, ���

CREATE OR REPLACE VIEW VIEW_PROFESSOR
AS
SELECT T.������, T.������, T.�����, T.���������, T.����������, T.�����̸�, T.�л��̸�, T.���, T.�Ǳ�
     , T.�ʱ�,(T.������� + T.�ʱ����� + T.�Ǳ�����)"����"
     , RANK() OVER(PARTITION BY T.������, T.����� ORDER BY (T.������� + T.�ʱ����� + T.�Ǳ�����)DESC)"���"
     , T.�ߵ�����     
FROM ( 
       SELECT PRO.NAME"������", SU.NAME"�����", OP.STARTDATE"���������", OP.ENDDATE"����������", SU.BOOK"�����̸�"
             , ST.NAME"�л��̸�", GR.ATTEND"���", GR.PRACTICE"�Ǳ�", GR.WRITTEN"�ʱ�"
             , FN_SCORE_PRACTICE(GR.GRADE_CODE)"�Ǳ�����"
             , FN_SCORE_WRITTEN(GR.GRADE_CODE)"�ʱ�����"
             , FN_SCORE_ATTEND(GR.GRADE_CODE)"�������"
             , OP.COUR_CODE"������"
             , FN_QUIT(RE.REG_CODE)"�ߵ�����"
  
        FROM TBL_OPSUBJECT OP LEFT JOIN TBL_PROFESSOR PRO
        ON PRO.PRO_ID = OP.PRO_ID
            LEFT JOIN TBL_SUBJECTS SU ON SU.SUB_CODE = OP.SUB_CODE
            LEFT JOIN TBL_GRADE GR ON GR.OPSUB_CODE = OP.OPSUB_CODE
            LEFT JOIN TBL_REGIST RE ON RE.REG_CODE = GR.REG_CODE
            LEFT JOIN TBL_STUDENT ST ON ST.STU_ID = RE.STU_ID    
)T;

-- �׽�Ʈ
-- �׳� ��ȸ �� ��� �� ��
SELECT * 
FROM VIEW_PROFESSOR;

-- WHERE ���� �ߵ����� ����
SELECT * 
FROM VIEW_PROFESSOR
WHERE �ߵ����� <> '�ߵ�����';



----------------------------------------
--�� �л�) ���� ��ȸ VIEW ���� (VIEW_STUDENT_GRADE)
-- ������� : �л���, ������, �����, �����Ⱓ(����,�� ��¥), �����
--           , ���, �ʱ�, �Ǳ�, ����, ���
-- �л�(�л���), ������û(������), ��������(�����), ����(����,����¥), ����(�����)
--           , ����(���, �Ǳ�, �ʱ�, ����, ���) -> �Լ����� (���� ���� ���)
----------------------------------------
CREATE OR REPLACE VIEW VIEW_STUDENT_GRADE
AS
SELECT T2.�л���, T2.������, T2.�����, T2.����������, T2.����������, T2.�����
    , T2.�������, T2.�ʱ�����, T2.�Ǳ�����, T2.����
    , RANK() OVER(PARTITION BY T2.������, T2.����� ORDER BY T2.���� DESC) "���"
FROM
(
    SELECT T1.�л���, T1.������, T1.�����, T1.����������, T1.����������, T1.�����
        , T1.�������, T1.�ʱ�����, T1.�Ǳ�����, (T1.������� + T1.�ʱ����� + T1.�Ǳ�����) "����"
    FROM
    (
    SELECT S.NAME "�л���", R.COUR_CODE "������", SJ.NAME "�����"
         , C.STARTDATE "����������", C.ENDDATE "����������", SJ.BOOK "�����"
    
         , FN_SCORE_PRACTICE(G.GRADE_CODE) "�Ǳ�����"
         , FN_SCORE_WRITTEN(G.GRADE_CODE) "�ʱ�����"
         , FN_SCORE_ATTEND(G.GRADE_CODE) "�������"   
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

    
-- ��ȸ
SELECT *
FROM VIEW_STUDENT_GRADE;


--==============================================================================
--���� �Լ�
--==============================================================================

--�۰��� ���� ��Ȳ�� ��ȯ�ϴ� �Լ�
CREATE OR REPLACE FUNCTION FN_COURSE
( V_COUR_CODE TBL_COURSE.COUR_CODE%TYPE
)
RETURN VARCHAR2
IS
    V_STARTDATE TBL_COURSE.STARTDATE%TYPE;
    V_ENDDATE   TBL_COURSE.ENDDATE%TYPE;
    
    V_RESULT VARCHAR2(40);
BEGIN
    SELECT STARTDATE, ENDDATE INTO V_STARTDATE, V_ENDDATE
    FROM TBL_COURSE
    WHERE COUR_CODE = V_COUR_CODE;
    
    IF (SYSDATE < V_STARTDATE)
        THEN V_RESULT := '���� ����';
    ELSIF ((V_STARTDATE < SYSDATE) AND (V_ENDDATE > SYSDATE )) 
        THEN V_RESULT := '���� ��';
    ELSIF (V_ENDDATE < SYSDATE)
        THEN V_RESULT := '���� ����';
    ELSE
        V_RESULT := '����Ȯ�κҰ�';
    END IF;
    
    RETURN V_RESULT;
    
END;


--�۰��������� ����, ���� �Է�����(������)�� ����ؼ� ��� ���� ���ϴ� �Լ�
CREATE OR REPLACE FUNCTION FN_SCORE_ATTEND
( V_GRADE_CODE TBL_GRADE.GRADE_CODE%TYPE
)
RETURN NUMBER
IS
    V_OPSUB_CODE TBL_GRADE.OPSUB_CODE%TYPE;
    V_ATTEND     TBL_GRADE.ATTEND%TYPE;     --�������
    V_ALLOT_CODE TBL_ALLOT.ALLOT_CODE%TYPE;
    
    V_ATTEND2     TBL_GRADE.ATTEND%TYPE;     --������
    V_RESULT NUMBER;
  
BEGIN
    -- ����
    SELECT OPSUB_CODE, ATTEND INTO V_OPSUB_CODE, V_ATTEND
    FROM TBL_GRADE
    WHERE GRADE_CODE = V_GRADE_CODE;
    
    -- �����ڵ�
    SELECT ALLOT_CODE INTO V_ALLOT_CODE
    FROM TBL_OPSUBJECT
    WHERE OPSUB_CODE = V_OPSUB_CODE;
    
    -- ����
    SELECT ATTEND INTO V_ATTEND2
    FROM TBL_ALLOT
    WHERE ALLOT_CODE = V_ALLOT_CODE;

    V_RESULT := (V_ATTEND * (V_ATTEND2/100));

    RETURN V_RESULT;
    
END;


--�۰��������� ����, ���� �Է�����(������)�� ����ؼ� �ʱ� ���� ���ϴ� �Լ�
CREATE OR REPLACE FUNCTION FN_SCORE_WRITTEN
( V_GRADE_CODE TBL_GRADE.GRADE_CODE%TYPE
)
RETURN NUMBER
IS
    V_OPSUB_CODE TBL_GRADE.OPSUB_CODE%TYPE;
    V_WRITTEN    TBL_GRADE.WRITTEN%TYPE;     --�ʱ�����
    V_ALLOT_CODE TBL_ALLOT.ALLOT_CODE%TYPE;
    
    V_WRITTEN2   TBL_GRADE.WRITTEN%TYPE;     --�ʱ����
    
    V_RESULT NUMBER;
  
BEGIN
    
    -- �������̺� (����, ���������ڵ�)
    SELECT OPSUB_CODE, WRITTEN INTO V_OPSUB_CODE, V_WRITTEN
    FROM TBL_GRADE 
    WHERE GRADE_CODE = V_GRADE_CODE;
    
    -- �����������̺� (�����ڵ�)
    SELECT ALLOT_CODE INTO V_ALLOT_CODE
    FROM TBL_OPSUBJECT
    WHERE OPSUB_CODE = V_OPSUB_CODE;
    
    -- �������̺� (�ʱ����)
    SELECT WRITTEN INTO V_WRITTEN2
    FROM TBL_ALLOT
    WHERE ALLOT_CODE = V_ALLOT_CODE;

    V_RESULT := (V_WRITTEN * (V_WRITTEN2/100));   

    RETURN V_RESULT;
    
END;


--�۰��������� ����, ���� �Է�����(������)�� ����ؼ� �Ǳ� ���� ���ϴ� �Լ�
CREATE OR REPLACE FUNCTION FN_SCORE_PRACTICE
( V_GRADE_CODE TBL_GRADE.GRADE_CODE%TYPE
)
RETURN NUMBER
IS
    V_OPSUB_CODE TBL_GRADE.OPSUB_CODE%TYPE;
    V_PRACTICE   TBL_GRADE.PRACTICE%TYPE;   --�Ǳ�����
    V_ALLOT_CODE TBL_ALLOT.ALLOT_CODE%TYPE;
    V_PRACTICE2   TBL_GRADE.PRACTICE%TYPE;   --�Ǳ����
    V_RESULT NUMBER;
BEGIN
    
    -- ����
    SELECT OPSUB_CODE, PRACTICE INTO V_OPSUB_CODE, V_PRACTICE
    FROM TBL_GRADE
    WHERE GRADE_CODE = V_GRADE_CODE;
    
    -- �����ڵ�
    SELECT ALLOT_CODE INTO V_ALLOT_CODE
    FROM TBL_OPSUBJECT
    WHERE OPSUB_CODE = V_OPSUB_CODE;
    
    -- ����
    SELECT PRACTICE INTO V_PRACTICE2
    FROM TBL_ALLOT
    WHERE ALLOT_CODE = V_ALLOT_CODE;

    V_RESULT := (V_PRACTICE * (V_PRACTICE2/100));
    
    RETURN V_RESULT;
    
END;


--���ߵ����� ���� Ȯ�� �Լ�
CREATE OR REPLACE FUNCTION FN_QUIT
( V_REG_CODE TBL_REGIST.REG_CODE%TYPE )
RETURN VARCHAR2
IS
    V_RESULT    VARCHAR2(30);
    V_COUNT     NUMBER;
    
BEGIN        
    SELECT COUNT(*) INTO V_COUNT
    FROM TBL_QUIT
    WHERE REG_CODE = V_REG_CODE;
     
       
    IF (V_COUNT >= 1)
        THEN V_RESULT := '�ߵ�����';
    ELSIF (V_COUNT = 0)
        THEN V_RESULT := '�ߵ����� �ƴ�';
    END IF;

    RETURN V_RESULT;       
END;


-- �׽�Ʈ
SELECT FN_QUIT(REG_CODE)
FROM TBL_REGIST;

SELECT FN_QUIT(2)
FROM DUAL;
---------------------------------
���̺� ���� ���� 


DROP TABLE TBL_ADMIN CASCADE CONSTRAINTS;       --������
DROP TABLE TBL_SUBJECTS CASCADE CONSTRAINTS;    --����
DROP TABLE TBL_CLASSROOM CASCADE CONSTRAINTS;   --���ǽ�
DROP TABLE TBL_ALLOT CASCADE CONSTRAINTS;       --����
DROP TABLE TBL_STUDENT CASCADE CONSTRAINTS;     --�л�
DROP TABLE TBL_PROFESSOR CASCADE CONSTRAINTS;   --����
DROP TABLE TBL_REGIST CASCADE CONSTRAINTS;      --������û
DROP TABLE TBL_COURSE CASCADE CONSTRAINTS;     --����
DROP TABLE TBL_QUIT CASCADE CONSTRAINTS;       --�ߵ�����
DROP TABLE TBL_OPSUBJECT CASCADE CONSTRAINTS;  --��������
DROP TABLE TBL_GRADE CASCADE CONSTRAINTS;      --����


purge recyclebin;

select *
from tabs;