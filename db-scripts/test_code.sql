SELECT * FROM arrivedtimetype;

INSERT INTO arrivedtimetype (code, name) 
VALUES (0, '테스트용');

SELECT * FROM emotions;

insert into emotions (name)
values ("happy");

SELECT * FROM goalhistories;

INSERT INTO goalhistories (
    content,
    createadAt, # 컬럼명 오타
    progressRate,
    goalsId
) VALUES (
    '테스트용 목표 내용입니다.',
    NOW(),
    0,
    1
);

select * from letters;

describe Letters;

INSERT INTO `FutureMe`.`letters` (`lettersId`, `title`, `content`, `expectedArrivalTime`, `isLocked`, `receiverType`, `isRead`, `senderId`, `receiverId`, `arrivedType`, `emotionsId`, `goalHistoriesId`, `parentLettersId`) VALUES ('1', '1', '1', '2025-01-01 10:00:00', '1', '1', '1', '9', '9', '1', '1', '1', '0');

