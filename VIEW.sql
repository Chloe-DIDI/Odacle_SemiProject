--�� �� VIEW ����

---------------------------------
     ������ ���� �� ���� 
----------------------------------
-- ������ ���� ���� ��ȸ
-- �����, ���� SDATE, ����EDATE, �����̸�, �л��̸�, ���, �Ǳ�, �ʱ�, ����, ���

CREATE OR REPLACE VIEW VIEW_PROFESSOR
AS


SELECT T.������, T.������, T.�����, T.���������, T.����������, T.�����̸�, T.�л��̸�, T.���, T.�Ǳ�
     , T.�ʱ�,(T.������� + T.�ʱ����� + T.�Ǳ�����)"����"
     , RANK() OVER(PARTITION BY T.������, T.����� ORDER BY (T.������� + T.�ʱ����� + T.�Ǳ�����)DESC)"���"
     
FROM ( 
       SELECT PRO.NAME"������", SU.NAME"�����", OP.STARTDATE"���������", OP.ENDDATE"����������", SU.BOOK"�����̸�"
             , ST.NAME"�л��̸�", GR.ATTEND"���", GR.PRACTICE"�Ǳ�", GR.WRITTEN"�ʱ�"
             , FN_SCORE_PRACTICE(GR.GRADE_CODE)"�Ǳ�����"
             , FN_SCORE_WRITTEN(GR.GRADE_CODE)"�ʱ�����"
             , FN_SCORE_ATTEND(GR.GRADE_CODE)"�������"
             , OP.COUR_CODE"������"
  
FROM TBL_OPSUBJECT OP LEFT JOIN TBL_PROFESSOR PRO
        ON PRO.PRO_ID = OP.PRO_ID
            LEFT JOIN TBL_SUBJECTS SU ON SU.SUB_CODE = OP.SUB_CODE
            LEFT JOIN TBL_GRADE GR ON GR.OPSUB_CODE = OP.OPSUB_CODE
            LEFT JOIN TBL_REGIST RE ON RE.REG_CODE = GR.REG_CODE
            LEFT JOIN TBL_STUDENT ST ON ST.STU_ID = RE.STU_ID
)T;











----------------------------------------
          ���� ���� �� ���� 
----------------------------------------

CREATE OR REPLACE VIEW VIEW_COURSE
AS

SELECT CO.COUR_CODE"������", CO.CLASS_CODE"���ǽǹ�ȣ", SU.NAME"�����"
     , CO.STARTDATE"������",CO.ENDDATE"������", SU.BOOK"�����̸�", PRO.NAME"�����ڸ�"
     , CL.CAPACITY"���ǽ� ����"
     , FN_COURSE(CO.COUR_CODE)"�������࿩��"

FROM TBL_PROFESSOR PRO RIGHT JOIN TBL_OPSUBJECT OP
ON PRO.PRO_ID = OP.PRO_ID
    LEFT JOIN TBL_SUBJECTS SU ON OP.SUB_CODE = SU.SUB_CODE
    RIGHT JOIN TBL_COURSE CO ON CO.COUR_CODE = OP.COUR_CODE
    LEFT JOIN TBL_CLASSROOM CL ON CL.CLASS_CODE = CO.CLASS_CODE;
    
    
���ǽǹ�ȣ���ȳ�����,,���ǽ� ������ ������
�������࿩�α��� �־��ֱ�

