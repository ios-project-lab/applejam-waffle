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


