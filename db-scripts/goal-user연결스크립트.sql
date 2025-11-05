-- 11/4 수정사항
-- 1-1. goal user 연결
-- 1-2. goal에 user 외래키 설정 
-- 2-1. goal deadLiine datetime-> date변경
-- 2-2. goal deadLine not null 로 변경

-- 1-1. goal에 user 컬럼 추가
ALTER TABLE Goals ADD COLUMN usersId INT NOT NULL;

-- 1-2. goal에 user 외래키 설정 
ALTER TABLE Goals
ADD CONSTRAINT fk_usersId
FOREIGN KEY (usersId)
REFERENCES Users(usersId)
ON DELETE RESTRICT;

-- 2-1. goal deadLiine datetime-> date변경
ALTER TABLE Goals MODIFY COLUMN deadLine Date;

-- 2-2. goal deadLine not null 로 변경 (만약 저장된 목표 있으면 지우고 하셔야 해요!!!)
ALTER TABLE Goals MODIFY COLUMN deadLine Date NOT NULL;

select * from Goals;