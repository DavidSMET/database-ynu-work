-- ========================================
-- 数据库案例 - SQL脚本
-- 04_高级特性.sql
-- 说明：演示SQL高级特性，包括索引、视图、存储过程、触发器
-- 对应讲义：重点讲义五 - SQL高级特性详解
-- ========================================

USE school_db;

-- ========================================
-- 第一部分：索引（Index）操作
-- ========================================

SELECT '--- 第一部分：索引操作 ---' AS '高级特性';

-- 1.1 创建索引
-- 为students表的name字段创建普通索引
CREATE INDEX IF NOT EXISTS idx_student_name ON students(name);

-- 为scores表的score字段创建普通索引
CREATE INDEX IF NOT EXISTS idx_score_value ON scores(score);

-- 为scores表的exam_date字段创建普通索引
CREATE INDEX IF NOT EXISTS idx_exam_date ON scores(exam_date);

-- 1.2 创建复合索引（遵循最左前缀原则）
CREATE INDEX IF NOT EXISTS idx_score_composite ON scores(student_id, course_id, score);

-- 1.3 查看索引
SHOW INDEX FROM students;
SHOW INDEX FROM scores;

-- 1.4 使用EXPLAIN分析查询（是否使用索引）
EXPLAIN SELECT * FROM students WHERE name = '张三';
EXPLAIN SELECT * FROM scores WHERE score > 90;

-- 1.5 删除索引
-- DROP INDEX idx_student_name ON students;

-- ========================================
-- 第二部分：视图（View）操作
-- ========================================

SELECT '--- 第二部分：视图操作 ---' AS '高级特性';

-- 2.1 创建基础视图：学生班级视图
CREATE OR REPLACE VIEW view_student_class AS
SELECT
    s.id AS student_id,
    s.name AS student_name,
    s.age,
    s.gender,
    s.phone,
    s.email,
    c.id AS class_id,
    c.name AS class_name,
    c.teacher AS class_teacher,
    c.room AS classroom
FROM students s
LEFT JOIN classes c ON s.class_id = c.id;

-- 查询视图
SELECT * FROM view_student_class WHERE age > 18 LIMIT 5;

-- 2.2 创建聚合视图：班级统计视图
CREATE OR REPLACE VIEW view_class_statistics AS
SELECT
    c.id AS class_id,
    c.name AS class_name,
    c.teacher,
    c.room,
    COUNT(s.id) AS student_count,
    ROUND(AVG(s.age), 1) AS avg_age,
    MAX(s.age) AS max_age,
    MIN(s.age) AS min_age,
    SUM(CASE WHEN s.gender = '男' THEN 1 ELSE 0 END) AS male_count,
    SUM(CASE WHEN s.gender = '女' THEN 1 ELSE 0 END) AS female_count
FROM classes c
LEFT JOIN students s ON c.id = s.class_id
GROUP BY c.id, c.name, c.teacher, c.room;

-- 查询视图
SELECT * FROM view_class_statistics;

-- 2.3 创建成绩视图：学生成绩详情视图
CREATE OR REPLACE VIEW view_student_scores AS
SELECT
    s.id AS student_id,
    s.name AS student_name,
    c.name AS class_name,
    co.id AS course_id,
    co.name AS course_name,
    co.teacher AS course_teacher,
    sc.score,
    sc.exam_date,
    sc.comment,
    CASE
        WHEN sc.score >= 90 THEN '优秀'
        WHEN sc.score >= 80 THEN '良好'
        WHEN sc.score >= 70 THEN '中等'
        WHEN sc.score >= 60 THEN '及格'
        ELSE '不及格'
    END AS grade_level
FROM scores sc
JOIN students s ON sc.student_id = s.id
JOIN classes c ON s.class_id = c.id
JOIN courses co ON sc.course_id = co.id;

-- 查询视图
SELECT * FROM view_student_scores WHERE student_id = 1;

-- 2.4 创建视图：成绩排名视图
CREATE OR REPLACE VIEW view_score_ranking AS
SELECT * FROM (
    SELECT
        co.name AS course_name,
        s.name AS student_name,
        sc.score,
        DENSE_RANK() OVER (
            PARTITION BY co.id
            ORDER BY sc.score DESC
        ) AS rank
    FROM scores sc
    JOIN students s ON sc.student_id = s.id
    JOIN courses co ON sc.course_id = co.id
) AS ranked
WHERE rank <= 3;

-- 查询视图：每门课程的前3名
SELECT * FROM view_score_ranking ORDER BY course_name, rank;

-- 2.5 查看所有视图
SHOW FULL TABLES WHERE TABLE_TYPE = 'VIEW';

-- 2.6 查看视图定义
SHOW CREATE VIEW view_student_class;

-- 2.7 更新视图（有限制）
UPDATE view_student_class SET age = 20 WHERE student_id = 1;

-- 2.8 删除视图
-- DROP VIEW IF EXISTS view_student_class;

-- ========================================
-- 第三部分：存储过程（Stored Procedure）
-- ========================================

SELECT '--- 第三部分：存储过程 ---' AS '高级特性';

-- 3.1 基础存储过程：按班级查询学生
DELIMITER //
DROP PROCEDURE IF EXISTS sp_get_students_by_class //
CREATE PROCEDURE sp_get_students_by_class(IN class_id INT)
BEGIN
    SELECT
        s.id,
        s.name,
        s.age,
        s.gender,
        c.name AS class_name
    FROM students s
    JOIN classes c ON s.class_id = c.id
    WHERE c.id = class_id
    ORDER BY s.id;
END //
DELIMITER ;

-- 调用存储过程
CALL sp_get_students_by_class(1);

-- 3.2 带输出参数的存储过程：统计学生人数
DELIMITER //
DROP PROCEDURE IF EXISTS sp_get_student_count //
CREATE PROCEDURE sp_get_student_count(OUT total_count INT, OUT avg_age DECIMAL(10,2))
BEGIN
    SELECT COUNT(*) INTO total_count FROM students;
    SELECT AVG(age) INTO avg_age FROM students;
END //
DELIMITER ;

-- 调用存储过程
CALL sp_get_student_count(@total, @avg_age);
SELECT @total AS 总学生数, @avg_age AS 平均年龄;

-- 3.3 带输入输出参数的存储过程：查询班级统计
DELIMITER //
DROP PROCEDURE IF EXISTS sp_get_class_statistics //
CREATE PROCEDURE sp_get_class_statistics(
    IN class_id INT,
    OUT student_count INT,
    OUT class_avg_age DECIMAL(10,2),
    OUT max_score DECIMAL(5,2)
)
BEGIN
    -- 统计学生人数和平均年龄
    SELECT COUNT(s.id), AVG(s.age)
    INTO student_count, class_avg_age
    FROM students s
    WHERE s.class_id = class_id;

    -- 查询最高分
    SELECT MAX(sc.score)
    INTO max_score
    FROM scores sc
    JOIN students s ON sc.student_id = s.id
    WHERE s.class_id = class_id;
END //
DELIMITER ;

-- 调用存储过程
CALL sp_get_class_statistics(1, @count, @avg_age, @max_score);
SELECT @count AS 学生人数, @avg_age AS 平均年龄, @max_score AS 最高分;

-- 3.4 使用游标的存储过程：批量更新班级人数
DELIMITER //
DROP PROCEDURE IF EXISTS sp_update_class_count //
CREATE PROCEDURE sp_update_class_count()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE class_id INT;
    DECLARE student_count INT;

    -- 声明游标
    DECLARE cur CURSOR FOR
        SELECT class_id, COUNT(*) AS count
        FROM students
        WHERE class_id IS NOT NULL
        GROUP BY class_id;

    -- 声明异常处理程序
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    -- 打开游标
    OPEN cur;

    -- 循环读取
    read_loop: LOOP
        FETCH cur INTO class_id, student_count;

        IF done THEN
            LEAVE read_loop;
        END IF;

        -- 更新班级人数
        UPDATE classes SET student_count = student_count WHERE id = class_id;
    END LOOP;

    -- 关闭游标
    CLOSE cur;
END //
DELIMITER ;

-- 调用存储过程
CALL sp_update_class_count();

-- 验证结果
SELECT name, student_count FROM classes;

-- 3.5 查看所有存储过程
SHOW PROCEDURE STATUS WHERE Db = 'school_db';

-- 3.6 查看存储过程定义
SHOW CREATE PROCEDURE sp_get_students_by_class;

-- ========================================
-- 第四部分：触发器（Trigger）
-- ========================================

SELECT '--- 第四部分：触发器 ---' AS '高级特性';

-- 4.1 INSERT触发器：记录学生插入日志
DELIMITER //
DROP TRIGGER IF EXISTS trg_student_insert //
CREATE TRIGGER trg_student_insert
AFTER INSERT ON students
FOR EACH ROW
BEGIN
    INSERT INTO audit_log (
        table_name,
        action,
        record_id,
        new_data
    ) VALUES (
        'students',
        'INSERT',
        NEW.id,
        JSON_OBJECT(
            'name', NEW.name,
            'age', NEW.age,
            'gender', NEW.gender,
            'class_id', NEW.class_id
        )
    );
END //
DELIMITER ;

-- 4.2 UPDATE触发器：记录学生更新日志
DELIMITER //
DROP TRIGGER IF EXISTS trg_student_update //
CREATE TRIGGER trg_student_update
AFTER UPDATE ON students
FOR EACH ROW
BEGIN
    -- 只有当关键字段发生变化时才记录
    IF NEW.name != OLD.name OR NEW.age != OLD.age THEN
        INSERT INTO audit_log (
            table_name,
            action,
            record_id,
            old_data,
            new_data
        ) VALUES (
            'students',
            'UPDATE',
            NEW.id,
            JSON_OBJECT(
                'name', OLD.name,
                'age', OLD.age,
                'gender', OLD.gender,
                'class_id', OLD.class_id
            ),
            JSON_OBJECT(
                'name', NEW.name,
                'age', NEW.age,
                'gender', NEW.gender,
                'class_id', NEW.class_id
            )
        );
    END IF;
END //
DELIMITER ;

-- 4.3 DELETE触发器：记录学生删除日志
DELIMITER //
DROP TRIGGER IF EXISTS trg_student_delete //
CREATE TRIGGER trg_student_delete
BEFORE DELETE ON students
FOR EACH ROW
BEGIN
    INSERT INTO audit_log (
        table_name,
        action,
        record_id,
        old_data
    ) VALUES (
        'students',
        'DELETE',
        OLD.id,
        JSON_OBJECT(
            'name', OLD.name,
            'age', OLD.age,
            'gender', OLD.gender,
            'class_id', OLD.class_id
        )
    );
END //
DELIMITER ;

-- 4.4 业务触发器：自动更新班级人数
DELIMITER //
DROP TRIGGER IF EXISTS trg_update_class_student_count //
CREATE TRIGGER trg_update_class_student_count
AFTER INSERT ON students
FOR EACH ROW
BEGIN
    IF NEW.class_id IS NOT NULL THEN
        UPDATE classes
        SET student_count = student_count + 1
        WHERE id = NEW.class_id;
    END IF;
END //
DELIMITER ;

DELIMITER //
DROP TRIGGER IF EXISTS trg_delete_class_student_count //
CREATE TRIGGER trg_delete_class_student_count
AFTER DELETE ON students
FOR EACH ROW
BEGIN
    IF OLD.class_id IS NOT NULL THEN
        UPDATE classes
        SET student_count = student_count - 1
        WHERE id = OLD.class_id;
    END IF;
END //
DELIMITER ;

-- 4.5 验证触发器：插入数据并检查审计日志
INSERT INTO students (name, age, gender, class_id, phone, email)
VALUES ('测试学生', 20, '男', 1, '13999999999', 'test@example.com');

-- 查看审计日志
SELECT * FROM audit_log ORDER BY created_at DESC LIMIT 3;

-- 查看班级人数是否自动更新
SELECT name, student_count FROM classes WHERE id = 1;

-- 4.6 查看所有触发器
SHOW TRIGGERS;

-- 4.7 查看触发器定义
SHOW CREATE TRIGGER trg_student_insert;

-- ========================================
-- 第五部分：事务（Transaction）示例
-- ========================================

SELECT '--- 第五部分：事务示例 ---' AS '高级特性';

-- 5.1 基础事务：转账示例
DELIMITER //
DROP PROCEDURE IF EXISTS sp_transfer_money //
CREATE PROCEDURE sp_transfer_money(
    IN from_student_id INT,
    IN to_student_id INT,
    IN amount DECIMAL(10,2)
)
BEGIN
    DECLARE from_balance DECIMAL(10,2);
    DECLARE to_balance DECIMAL(10,2);

    -- 开启事务
    START TRANSACTION;

    -- 1. 检查转出学生是否存在
    SELECT COUNT(*) INTO @count FROM students WHERE id = from_student_id;
    IF @count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '转出学生不存在';
    END IF;

    -- 2. 检查转入学生是否存在
    SELECT COUNT(*) INTO @count FROM students WHERE id = to_student_id;
    IF @count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '转入学生不存在';
    END IF;

    -- 3. 模拟转账逻辑（这里仅作演示）
    -- 实际应用中应该有余额表
    SELECT '转账成功' AS result;

    -- 提交事务
    COMMIT;
END //
DELIMITER ;

-- 5.2 事务示例：批量插入并回滚
START TRANSACTION;

-- 插入多条数据
INSERT INTO students (name, age, gender, class_id, phone, email) VALUES
    ('测试1', 20, '男', 1, '13800000001', 'test1@example.com'),
    ('测试2', 21, '女', 1, '13800000002', 'test2@example.com'),
    ('测试3', 22, '男', 1, '13800000003', 'test3@example.com');

-- 设置保存点
SAVEPOINT sp1;

-- 再插入一条数据
INSERT INTO students (name, age, gender, class_id, phone, email)
VALUES ('测试4', 23, '女', 1, '13800000004', 'test4@example.com');

-- 回滚到保存点（撤销最后一条插入）
ROLLBACK TO sp1;

-- 提交事务（只保存前三条）
COMMIT;

-- 验证结果
SELECT * FROM students WHERE name LIKE '测试%';

-- 5.3 查看事务隔离级别
SELECT @@transaction_isolation;

-- 设置隔离级别
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

-- ========================================
-- 第六部分：窗口函数（Window Functions）
-- ========================================

SELECT '--- 第六部分：窗口函数 ---' AS '高级特性';

-- 6.1 ROW_NUMBER：排名
SELECT
    s.name AS 学生姓名,
    co.name AS 课程名称,
    sc.score AS 成绩,
    ROW_NUMBER() OVER (PARTITION BY co.id ORDER BY sc.score DESC) AS 排名
FROM scores sc
JOIN students s ON sc.student_id = s.id
JOIN courses co ON sc.course_id = co.id
WHERE co.id IN (1, 2)
ORDER BY co.id, 排名;

-- 6.2 RANK：相同分数排名相同，跳过后续排名
SELECT
    s.name AS 学生姓名,
    co.name AS 课程名称,
    sc.score AS 成绩,
    RANK() OVER (PARTITION BY co.id ORDER BY sc.score DESC) AS 排名
FROM scores sc
JOIN students s ON sc.student_id = s.id
JOIN courses co ON sc.course_id = co.id
ORDER BY co.id, 排名;

-- 6.3 DENSE_RANK：相同分数排名相同，不跳过后续排名
SELECT
    s.name AS 学生姓名,
    co.name AS 课程名称,
    sc.score AS 成绩,
    DENSE_RANK() OVER (PARTITION BY co.id ORDER BY sc.score DESC) AS 排名
FROM scores sc
JOIN students s ON sc.student_id = s.id
JOIN courses co ON sc.course_id = co.id
ORDER BY co.id, 排名;

-- 6.4 SUM累计和
SELECT
    sc.exam_date AS 考试日期,
    co.name AS 课程名称,
    sc.score AS 成绩,
    SUM(sc.score) OVER (
        ORDER BY sc.exam_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS 累计成绩
FROM scores sc
JOIN courses co ON sc.course_id = co.id
WHERE sc.student_id = 1
ORDER BY sc.exam_date;

-- 6.5 LAG/LEAD：获取前后行的值
SELECT
    s.name AS 学生姓名,
    co.name AS 课程名称,
    sc.score AS 成绩,
    LAG(sc.score, 1, 0) OVER (
        PARTITION BY s.id
        ORDER BY sc.exam_date
    ) AS 上一次成绩,
    LEAD(sc.score, 1, 0) OVER (
        PARTITION BY s.id
        ORDER BY sc.exam_date
    ) AS 下一次成绩
FROM scores sc
JOIN students s ON sc.student_id = s.id
JOIN courses co ON sc.course_id = co.id
WHERE s.id IN (1, 2)
ORDER BY s.id, sc.exam_date;

-- 6.6 FIRST_VALUE/LAST_VALUE
SELECT
    s.name AS 学生姓名,
    co.name AS 课程名称,
    sc.score AS 成绩,
    FIRST_VALUE(sc.score) OVER (
        PARTITION BY co.id
        ORDER BY sc.score DESC
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS 本门课程最高分,
    LAST_VALUE(sc.score) OVER (
        PARTITION BY co.id
        ORDER BY sc.score DESC
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS 本门课程最低分
FROM scores sc
JOIN students s ON sc.student_id = s.id
JOIN courses co ON sc.course_id = co.id
WHERE co.id = 1
ORDER BY sc.score DESC;

-- ========================================
-- 第七部分：CTE（公用表表达式）
-- ========================================

SELECT '--- 第七部分：CTE公用表表达式 ---' AS '高级特性';

-- 7.1 基础CTE：简化复杂查询
WITH adult_students AS (
    SELECT * FROM students WHERE age >= 18
)
SELECT
    a.*,
    c.name AS class_name
FROM adult_students a
LEFT JOIN classes c ON a.class_id = c.id;

-- 7.2 多个CTE：统计大班人数
WITH
    adult_students AS (
        SELECT class_id FROM students WHERE age >= 18
    ),
    large_classes AS (
        SELECT DISTINCT class_id FROM adult_students
    )
SELECT
    c.name AS 班级名称,
    COUNT(DISTINCT a.class_id) AS 成年学生人数
FROM classes c
JOIN large_classes a ON c.id = a.class_id
GROUP BY c.id, c.name;

-- 7.3 CTE与窗口函数结合：计算累计销售额
WITH monthly_sales AS (
    SELECT
        EXTRACT(YEAR FROM exam_date) AS year,
        EXTRACT(MONTH FROM exam_date) AS month,
        COUNT(*) AS exam_count,
        SUM(score) AS total_score
    FROM scores
    GROUP BY year, month
    ORDER BY year, month
)
SELECT
    year AS 年份,
    month AS 月份,
    exam_count AS 考试人数,
    total_score AS 总分,
    SUM(total_score) OVER (
        ORDER BY year, month
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS 累计总分
FROM monthly_sales;

-- ========================================
-- 总结
-- ========================================

SELECT '=== 高级特性演示完成 ===' AS '总结';
SELECT
    (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
     WHERE TABLE_SCHEMA = 'school_db' AND TABLE_TYPE = 'BASE TABLE') AS 基础表数量,
    (SELECT COUNT(*) FROM INFORMATION_SCHEMA.VIEWS
     WHERE TABLE_SCHEMA = 'school_db') AS 视图数量,
    (SELECT COUNT(*) FROM INFORMATION_SCHEMA.ROUTINES
     WHERE ROUTINE_SCHEMA = 'school_db' AND ROUTINE_TYPE = 'PROCEDURE') AS 存储过程数量,
    (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TRIGGERS
     WHERE TRIGGER_SCHEMA = 'school_db') AS 触发器数量,
    (SELECT COUNT(*) FROM audit_log) AS 审计日志数量;