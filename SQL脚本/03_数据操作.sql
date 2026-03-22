-- ========================================
-- 数据库案例 - SQL脚本
-- 03_数据操作.sql
-- 说明：演示CRUD操作和各种查询技巧
-- 对应讲义：重点讲义一、二 - DML/DQL详解
-- ========================================

USE school_db;

-- ========================================
-- 第一部分：CREATE - 插入数据（INSERT）
-- ========================================

-- 1.1 插入班级数据（完整插入）
INSERT INTO classes (name, teacher, room) VALUES
    ('一年级一班', '王老师', '101教室'),
    ('一年级二班', '李老师', '102教室'),
    ('二年级一班', '张老师', '201教室'),
    ('二年级二班', '刘老师', '202教室');

-- 1.2 插入学生数据（使用枚举类型）
INSERT INTO students (name, age, gender, class_id, phone, email, birthday) VALUES
    ('张三', 18, '男', 1, '13800138001', 'zhangsan@example.com', '2008-01-15'),
    ('李四', 17, '女', 1, '13800138002', 'lisi@example.com', '2009-03-20'),
    ('王五', 19, '男', 2, '13800138003', 'wangwu@example.com', '2007-05-10'),
    ('赵六', 18, '女', 2, '13800138004', 'zhaoliu@example.com', '2008-07-25'),
    ('钱七', 17, '男', 3, '13800138005', 'qianqi@example.com', '2009-09-30'),
    ('孙八', 19, '女', 3, '13800138006', 'sunba@example.com', '2007-11-12'),
    ('周九', 20, '男', 4, '13800138007', 'zhoujiu@example.com', '2006-02-28'),
    ('吴十', 18, '女', 4, '13800138008', 'wushi@example.com', '2008-04-05');

-- 1.3 插入课程数据（使用TEXT类型和FULLTEXT索引）
INSERT INTO courses (name, credit, teacher, description, is_required) VALUES
    ('数学', 4.0, '陈老师', '高等数学基础课程，包含微积分、线性代数等', 1),
    ('英语', 3.0, '林老师', '大学英语综合课程，提高听说读写能力', 1),
    ('计算机基础', 3.5, '黄老师', '计算机入门课程，学习编程基础', 1),
    ('数据库原理', 4.0, '赵老师', '关系型数据库设计与管理，SQL语言', 1),
    ('体育', 2.0, '郑老师', '体育锻炼课程，增强身体素质', 0);

-- 1.4 插入成绩数据（使用UNIQUE约束防止重复）
INSERT INTO scores (student_id, course_id, score, exam_date, comment) VALUES
    (1, 1, 85.50, '2026-01-15', '基础扎实'),
    (1, 2, 90.00, '2026-01-16', '表现优秀'),
    (1, 3, 88.50, '2026-01-17', '逻辑清晰'),
    (1, 4, 92.00, '2026-01-18', '理解深刻'),
    (2, 1, 92.00, '2026-01-15', '成绩优异'),
    (2, 2, 87.50, '2026-01-16', '进步明显'),
    (2, 3, 95.00, '2026-01-17', '技术突出'),
    (3, 1, 78.00, '2026-01-15', '需要努力'),
    (3, 3, 85.00, '2026-01-17', '掌握较好'),
    (4, 2, 91.00, '2026-01-16', '语音标准'),
    (4, 4, 89.50, '2026-01-18', '思维敏捷'),
    (5, 1, 88.00, '2026-01-15', '方法得当'),
    (6, 2, 93.50, '2026-01-16', '表达流利'),
    (7, 3, 90.00, '2026-01-17', '动手能力强'),
    (8, 4, 94.00, '2026-01-18', '理解深入');

-- 验证插入结果
SELECT '班级数据：' AS '=== 插入数据验证 ===';
SELECT * FROM classes;
SELECT '学生数据（前5条）：';
SELECT * FROM students LIMIT 5;
SELECT '课程数据：';
SELECT * FROM courses;
SELECT '成绩数据（前5条）：';
SELECT * FROM scores LIMIT 5;

-- ========================================
-- 第二部分：READ - 查询数据（SELECT）
-- ========================================

-- 2.1 基础查询
SELECT '--- 2.1 基础查询 ---' AS '查询类型';
-- 查询所有列（不推荐生产环境使用）
SELECT * FROM students LIMIT 3;

-- 查询指定列（推荐）
SELECT id, name, age, gender FROM students;

-- 使用列别名
SELECT
    id AS 学生ID,
    name AS 姓名,
    age AS 年龄,
    gender AS 性别
FROM students;

-- 去重查询
SELECT DISTINCT class_id FROM students;
SELECT DISTINCT gender FROM students;

-- 2.2 条件查询（WHERE）
SELECT '--- 2.2 条件查询 ---' AS '查询类型';
-- 比较运算符
SELECT * FROM students WHERE age = 18;
SELECT * FROM students WHERE age > 18;
SELECT * FROM students WHERE age BETWEEN 17 AND 19;

-- 逻辑运算符
SELECT * FROM students WHERE age > 18 AND gender = '男';
SELECT * FROM students WHERE age < 18 OR gender = '女';

-- IN查询
SELECT * FROM students WHERE class_id IN (1, 2, 3);
SELECT * FROM students WHERE class_id NOT IN (4);

-- NULL值查询
SELECT * FROM students WHERE email IS NOT NULL;
SELECT * FROM students WHERE address IS NULL;

-- 2.3 模糊查询（LIKE）
SELECT '--- 2.3 模糊查询 ---' AS '查询类型';
-- % 匹配任意多个字符
SELECT * FROM students WHERE name LIKE '张%';
SELECT * FROM students WHERE email LIKE '%@example.com';
SELECT * FROM students WHERE name LIKE '%王%';

-- _ 匹配单个字符
SELECT * FROM students WHERE name LIKE '张_';

-- 正则表达式（MySQL）
SELECT * FROM students WHERE phone REGEXP '^1[3-9][0-9]{9}$';

-- 2.4 排序（ORDER BY）
SELECT '--- 2.4 排序 ---' AS '查询类型';
-- 单字段排序
SELECT name, age FROM students ORDER BY age DESC;

-- 多字段排序
SELECT name, class_id, age FROM students
ORDER BY class_id ASC, age DESC;

-- 按计算结果排序
SELECT name, age, 2026 - age AS birth_year
FROM students
ORDER BY birth_year;

-- 2.5 分页查询（LIMIT）
SELECT '--- 2.5 分页查询 ---' AS '查询类型';
-- 查询前5条
SELECT * FROM students LIMIT 5;

-- 查询第6-10条（分页公式：LIMIT page_size OFFSET (page-1)*page_size）
SELECT * FROM students LIMIT 5 OFFSET 5;

-- MySQL简写：LIMIT offset, page_size
SELECT * FROM students LIMIT 5, 5;

-- 2.6 聚合函数
SELECT '--- 2.6 聚合函数 ---' AS '查询类型';
-- COUNT：计数
SELECT COUNT(*) AS 总学生数 FROM students;
SELECT COUNT(DISTINCT class_id) AS 班级数 FROM students;

-- SUM：求和
SELECT SUM(score) AS 总成绩 FROM scores;

-- AVG：平均值
SELECT AVG(age) AS 平均年龄 FROM students;
SELECT ROUND(AVG(score), 2) AS 平均成绩 FROM scores;

-- MAX/MIN：最大/最小值
SELECT MAX(age) AS 最大年龄, MIN(age) AS 最小年龄 FROM students;
SELECT MAX(score) AS 最高分, MIN(score) AS 最低分 FROM scores;

-- 2.7 分组统计（GROUP BY）
SELECT '--- 2.7 分组统计 ---' AS '查询类型';
-- 按性别分组统计
SELECT
    gender,
    COUNT(*) AS 人数,
    AVG(age) AS 平均年龄,
    MAX(age) AS 最大年龄
FROM students
GROUP BY gender;

-- 按班级分组统计
SELECT
    c.name AS 班级名称,
    COUNT(s.id) AS 学生人数,
    ROUND(AVG(s.age), 1) AS 平均年龄
FROM classes c
LEFT JOIN students s ON c.id = s.class_id
GROUP BY c.id, c.name
ORDER BY COUNT(s.id) DESC;

-- 分组后过滤（HAVING）
SELECT
    c.name AS 班级名称,
    COUNT(s.id) AS 学生人数
FROM classes c
LEFT JOIN students s ON c.id = s.class_id
GROUP BY c.id, c.name
HAVING COUNT(s.id) > 1;

-- 2.8 连接查询（JOIN）
SELECT '--- 2.8 连接查询 ---' AS '查询类型';
-- 内连接（INNER JOIN）：只返回匹配的行
SELECT
    s.id,
    s.name AS 学生姓名,
    s.age,
    c.name AS 班级名称,
    c.teacher AS 班主任
FROM students s
INNER JOIN classes c ON s.class_id = c.id;

-- 左连接（LEFT JOIN）：返回左表所有行
SELECT
    s.name AS 学生姓名,
    c.name AS 班级名称
FROM students s
LEFT JOIN classes c ON s.class_id = c.id;

-- 三表连接：查询学生成绩详情
SELECT
    s.name AS 学生姓名,
    c.name AS 班级名称,
    co.name AS 课程名称,
    sc.score AS 成绩,
    sc.exam_date AS 考试日期,
    sc.comment AS 评语
FROM scores sc
JOIN students s ON sc.student_id = s.id
JOIN classes c ON s.class_id = c.id
JOIN courses co ON sc.course_id = co.id
ORDER BY s.name, sc.score DESC;

-- 2.9 子查询
SELECT '--- 2.9 子查询 ---' AS '查询类型';
-- 标量子查询
SELECT * FROM students
WHERE age > (SELECT AVG(age) FROM students);

-- 列表子查询
SELECT * FROM classes
WHERE id IN (SELECT DISTINCT class_id FROM students WHERE age > 18);

-- EXISTS子查询
SELECT * FROM courses c
WHERE EXISTS (
    SELECT 1 FROM scores sc
    WHERE sc.course_id = c.id AND sc.score >= 90
);

-- 2.10 UNION合并查询
SELECT '--- 2.10 UNION合并查询 ---' AS '查询类型';
-- UNION：合并并去重
SELECT name, age FROM students WHERE age > 18
UNION
SELECT name, age FROM students WHERE gender = '女';

-- UNION ALL：合并不去重
SELECT name, age FROM students WHERE age > 18
UNION ALL
SELECT name, age FROM students WHERE gender = '女';

-- ========================================
-- 第三部分：UPDATE - 更新数据
-- ========================================

SELECT '--- 第三部分：UPDATE更新数据 ---' AS '操作类型';

-- 3.1 更新单个字段
UPDATE students SET age = 19 WHERE id = 1;

-- 3.2 更新多个字段
UPDATE students
SET age = 20, phone = '13900139001'
WHERE id = 2;

-- 3.3 批量更新
UPDATE students
SET is_active = 0
WHERE age < 17;

-- 3.4 使用子查询更新
UPDATE students
SET class_id = (SELECT id FROM classes WHERE name = '一年级一班')
WHERE name = '张三' AND class_id IS NULL;

-- 3.5 条件更新
UPDATE scores
SET score = score * 1.05
WHERE score < 80;

-- 验证更新结果
SELECT * FROM students WHERE id IN (1, 2);

-- ========================================
-- 第四部分：DELETE - 删除数据
-- ========================================

SELECT '--- 第四部分：DELETE删除数据 ---' AS '操作类型';

-- ⚠️ 注意：删除操作前建议先查询确认！
-- 4.1 删除单条记录
-- 先查询
SELECT * FROM scores WHERE student_id = 8 AND course_id = 5;
-- 再删除
DELETE FROM scores WHERE student_id = 8 AND course_id = 5;

-- 4.2 删除多条记录（带条件）
-- 先查询
SELECT * FROM students WHERE age < 17;
-- 再删除
DELETE FROM students WHERE age < 17;

-- 4.3 使用子查询删除
DELETE FROM scores
WHERE student_id IN (
    SELECT id FROM students WHERE is_active = 0
);

-- 4.4 清空表（保留表结构）
-- TRUNCATE TABLE scores;
-- ⚠️ 警告：TRUNCATE会重置自增ID，不能回滚

-- 验证删除结果
SELECT COUNT(*) AS 剩余学生数 FROM students;

-- ========================================
-- 第五部分：高级查询示例
-- ========================================

SELECT '--- 第五部分：高级查询示例 ---' AS '查询类型';

-- 5.1 查询每门课程的前3名学生（窗口函数）
SELECT * FROM (
    SELECT
        s.name AS 学生姓名,
        co.name AS 课程名称,
        sc.score AS 成绩,
        ROW_NUMBER() OVER (
            PARTITION BY co.id
            ORDER BY sc.score DESC
        ) AS 排名
    FROM scores sc
    JOIN students s ON sc.student_id = s.id
    JOIN courses co ON sc.course_id = co.id
) AS ranked
WHERE 排名 <= 3
ORDER BY 课程名称, 排名;

-- 5.2 查询每个班级的性别分布
SELECT
    c.name AS 班级,
    s.gender AS 性别,
    COUNT(*) AS 人数,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY c.id), 2) AS 百分比
FROM classes c
LEFT JOIN students s ON c.id = s.class_id
GROUP BY c.id, c.name, s.gender
ORDER BY c.id, s.gender;

-- 5.3 查询成绩优秀的学生（>=90分）
SELECT DISTINCT
    s.name AS 学生姓名,
    c.name AS 班级
FROM students s
JOIN scores sc ON s.id = sc.student_id
JOIN classes c ON s.class_id = c.id
WHERE sc.score >= 90
ORDER BY c.name, s.name;

-- 5.4 统计每个班级的平均成绩
SELECT
    c.name AS 班级,
    COUNT(DISTINCT s.id) AS 学生人数,
    ROUND(AVG(sc.score), 2) AS 平均成绩,
    MAX(sc.score) AS 最高分,
    MIN(sc.score) AS 最低分
FROM classes c
LEFT JOIN students s ON c.id = s.class_id
LEFT JOIN scores sc ON s.id = sc.student_id
GROUP BY c.id, c.name
ORDER BY AVG(sc.score) DESC;

-- 5.5 查询没有成绩的学生
SELECT
    s.name AS 学生姓名,
    c.name AS 班级
FROM students s
LEFT JOIN classes c ON s.class_id = c.id
LEFT JOIN scores sc ON s.id = sc.student_id
WHERE sc.id IS NULL;

-- ========================================
-- 第六部分：全文搜索示例（FULLTEXT索引）
-- ========================================

SELECT '--- 第六部分：全文搜索 ---' AS '查询类型';

-- 使用全文搜索（需要FULLTEXT索引）
SELECT name, description
FROM courses
WHERE MATCH(description) AGAINST('数据库' IN NATURAL LANGUAGE MODE);

-- ========================================
-- 总结
-- ========================================

SELECT '=== 数据操作完成 ===' AS '总结';
SELECT
    (SELECT COUNT(*) FROM classes) AS 班级数,
    (SELECT COUNT(*) FROM students) AS 学生数,
    (SELECT COUNT(*) FROM courses) AS 课程数,
    (SELECT COUNT(*) FROM scores) AS 成绩记录数;
