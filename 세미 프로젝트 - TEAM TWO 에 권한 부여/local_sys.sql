-- ���� team two �� ���� �ο� 

CREATE TABLESPACE TBS_TEAM                  -- CREATE ��������, ��ü�� �� ����
DATAFILE 'C:\TESTORADATA\TBS_TEAM01.DBF'    -- ���������� ����Ǵ� ������ ����
SIZE 4M                                     -- ������ ������ ������ �뷮
EXTENT MANAGEMENT LOCAL                     -- ����Ŭ ������ ���׸�Ʈ�� �˾Ƽ� ����
SEGMENT SPACE MANAGEMENT AUTO;              -- ���׸�Ʈ ���� ������ �ڵ����� ����Ŭ ������ ����               




CREATE USER two IDENTIFIED BY tiger
DEFAULT TABLESPACE TBS_TEAM;


GRANT CREATE SESSION TO two;
GRANT CREATE TABLE TO two;
GRANT CREATE PROCEDURE TO two;

ALTER USER two
QUOTA UNLIMITED ON TBS_TEAM;


SET SERVEROUTPUT ON;
