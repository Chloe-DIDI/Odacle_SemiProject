SELECT USER
FROM DUAL;
--==>> SYS


CREATE TABLESPACE TBS_TEAM                  -- CREATE 만들유형, 개체명 → 생성
DATAFILE 'C:\TESTORADATA\TBS_TEAM01.DBF'    -- 물리적으로 연결되는 데이터 파일
SIZE 4M                                     -- 물리적 데이터 파일의 용량
EXTENT MANAGEMENT LOCAL                     -- 오라클 서버가 세그먼트를 알아서 관리
SEGMENT SPACE MANAGEMENT AUTO;              -- 세그먼트 공간 관리도 자동으로 오라클 서버에 위임               




CREATE USER two IDENTIFIED BY tiger
DEFAULT TABLESPACE TBS_TEAM;


GRANT CREATE SESSION TO two;
GRANT CREATE TABLE TO two;
GRANT CREATE PROCEDURE TO two;
GRANT CREATE VIEW TO two;
GRANT CREATE TRIGGER TO two;

GRANT CREATE TRIGGER TO two;

ALTER USER two
QUOTA UNLIMITED ON TBS_TEAM;


SET SERVEROUTPUT ON;
