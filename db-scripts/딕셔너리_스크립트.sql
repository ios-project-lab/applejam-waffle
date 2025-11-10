use FutureMe;
-- step1. 테이블 이름, 컬럼 수정
ALTER TABLE NotificationType MODIFY code VARCHAR(50);
ALTER TABLE FriendStatus MODIFY code VARCHAR(50);
ALTER TABLE Categories MODIFY code VARCHAR(50);
ALTER TABLE ArrivedTimeType MODIFY code VARCHAR(50);

ALTER TABLE FriendSNotificationTypetatus RENAME TO FriendStatus;

-- step2. 새로운 테이블 생성 쿼리
-- 성별
CREATE TABLE Gender (
    code VARCHAR(10) NOT NULL,
    name VARCHAR(10) NOT NULL
);
-- 회원 상태
CREATE TABLE UserStatus (
    code VARCHAR(20) NOT NULL,
    name VARCHAR(20) NOT NULL
);
-- 편지 수신 대상
CREATE TABLE ReceiverType (
    code VARCHAR(20) NOT NULL,
    name VARCHAR(20) NOT NULL
);

-- step3. 데이터 삽입

-- NotificationType (알림 유형)
INSERT INTO NotificationType (code, name) VALUES
('ARRIVE', '도착 알림'),
('GOAL', '목표 알림'),
('FRIEND', '친구 요청 알림');

-- FriendStatus (친구 상태 코드)
INSERT INTO FriendStatus (code, name) VALUES
('PENDING', '요청 중'),
('ACCEPTED', '수락됨'),
('REJECTED', '거절됨'),
('CANCELED', '취소됨'),
('BLOCKED', '차단됨');

--  Categories (목표 카테고리)
INSERT INTO Categories (code, name) VALUES
('HEALTH', '건강'),
('STUDY', '공부'),
('HABIT', '습관'),
('RELATION', '관계'),
('EMPLOYMENT', '취업'),
('ETC', '기타');

-- ArrivedTimeType (편지 도착 예상 시간)
INSERT INTO ArrivedTimeType (code, name) VALUES
('TOMORROW', '내일'),
('WEEK', '일주일 후'),
('MONTH', '한 달 후'),
('AI', 'AI 추천'),
('CUSTOM', '사용자 지정');

-- Emotions (감정 종류)
INSERT INTO Emotions (name) VALUES
('기쁨'),
('우울'),
('보통'),
('분노'),
('놀람'),
('감사');

-- ReceiverType (편지 수신 대상)
INSERT INTO ReceiverType (code, name) VALUES
('ME', '나에게'),
('FRIEND', '친구에게');

-- Gender (성별 구분)
INSERT INTO Gender (code, name) VALUES
('MALE', '남성'),
('FEMALE', '여성'),
('NONE', '없음');

-- Status (회원 상태)
INSERT INTO UserStatus (code, name) VALUES
('REGISTERING', '가입 중'),
('REGISTERED', '가입 완료'),
('WITHDRAWN', '탈퇴'),
('BLOCKED', '차단 중');


