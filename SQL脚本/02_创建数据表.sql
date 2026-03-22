-- ========================================
-- 数据库案例 - SQL脚本
-- 02_创建数据表.sql
-- 说明：创建完整的数据表结构，包含外键约束和索引
-- 对应讲义：重点讲义三 - 数据库设计与外键关系
-- ========================================

USE school_db;

-- ========================================
-- 创建班级表（classes）
-- ========================================
CREATE TABLE IF NOT EXISTS classes (
    id INT PRIMARY KEY AUTO_INCREMENT COMMENT '班级ID，主键自增',
    name VARCHAR(50) NOT NULL COMMENT '班级名称',
    teacher VARCHAR(50) COMMENT '班主任姓名',
    room VARCHAR(30) COMMENT '教室位置',
    student_count INT DEFAULT 0 COMMENT '学生人数（冗余字段）',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',

    -- 索引
    INDEX idx_name (name),
    INDEX idx_teacher (teacher)

) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='班级信息表';

-- ========================================
-- 创建学生表（students）
-- ========================================
CREATE TABLE IF NOT EXISTS students (
    id INT PRIMARY KEY AUTO_INCREMENT COMMENT '学生ID，主键自增',
    name VARCHAR(50) NOT NULL COMMENT '学生姓名',
    age INT COMMENT '年龄',
    gender ENUM('男', '女', '其他') DEFAULT '其他' COMMENT '性别（枚举类型）',
    class_id INT COMMENT '班级ID，外键',
    phone CHAR(11) COMMENT '联系电话（固定11位）',
    email VARCHAR(100) UNIQUE COMMENT '电子邮箱（唯一约束）',
    address VARCHAR(200) COMMENT '家庭住址',
    birthday DATE COMMENT '出生日期',
    is_active TINYINT(1) DEFAULT 1 COMMENT '是否激活（布尔值：0或1）',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',

    -- 外键约束：关联班级表
    CONSTRAINT fk_student_class
        FOREIGN KEY (class_id)
        REFERENCES classes(id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,

    -- 约束：年龄范围
    CONSTRAINT chk_age CHECK (age >= 0 AND age <= 150),

    -- 索引
    INDEX idx_name (name),
    INDEX idx_class_id (class_id),
    INDEX idx_phone (phone),
    INDEX idx_email (email)

) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='学生信息表';

-- ========================================
-- 创建课程表（courses）
-- ========================================
CREATE TABLE IF NOT EXISTS courses (
    id INT PRIMARY KEY AUTO_INCREMENT COMMENT '课程ID',
    name VARCHAR(100) NOT NULL COMMENT '课程名称',
    credit DECIMAL(3,1) COMMENT '学分（3位数字，1位小数）',
    teacher VARCHAR(50) COMMENT '授课教师',
    description TEXT COMMENT '课程描述',
    is_required TINYINT(1) DEFAULT 1 COMMENT '是否必修（0或1）',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',

    -- 索引
    INDEX idx_name (name),
    INDEX idx_teacher (teacher),
    FULLTEXT INDEX idx_description (description)

) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='课程信息表';

-- ========================================
-- 创建成绩表（scores）- 学生与课程的多对多关系
-- ========================================
CREATE TABLE IF NOT EXISTS scores (
    id INT PRIMARY KEY AUTO_INCREMENT COMMENT '成绩ID',
    student_id INT NOT NULL COMMENT '学生ID',
    course_id INT NOT NULL COMMENT '课程ID',
    score DECIMAL(5,2) COMMENT '成绩（5位数字，2位小数）',
    exam_date DATE COMMENT '考试日期',
    comment VARCHAR(200) COMMENT '评语',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',

    -- 外键约束：关联学生表（级联删除）
    CONSTRAINT fk_score_student
        FOREIGN KEY (student_id)
        REFERENCES students(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    -- 外键约束：关联课程表（级联删除）
    CONSTRAINT fk_score_course
        FOREIGN KEY (course_id)
        REFERENCES courses(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    -- 联合唯一索引：一个学生一门课程只有一个成绩
    UNIQUE KEY uk_student_course (student_id, course_id),

    -- 约束：成绩范围
    CONSTRAINT chk_score CHECK (score >= 0 AND score <= 100),

    -- 索引
    INDEX idx_student_id (student_id),
    INDEX idx_course_id (course_id),
    INDEX idx_score (score),
    INDEX idx_exam_date (exam_date)

) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='学生成绩表';

-- ========================================
-- 创建审计日志表（audit_log）- 用于触发器
-- ========================================
CREATE TABLE IF NOT EXISTS audit_log (
    id INT AUTO_INCREMENT PRIMARY KEY COMMENT '日志ID',
    table_name VARCHAR(50) NOT NULL COMMENT '表名',
    action VARCHAR(10) NOT NULL COMMENT '操作类型（INSERT/UPDATE/DELETE）',
    record_id INT COMMENT '记录ID',
    old_data TEXT COMMENT '旧数据（JSON格式）',
    new_data TEXT COMMENT '新数据（JSON格式）',
    user_id INT COMMENT '操作用户ID',
    ip_address VARCHAR(45) COMMENT 'IP地址',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '操作时间',

    -- 索引
    INDEX idx_table_name (table_name),
    INDEX idx_action (action),
    INDEX idx_created_at (created_at)

) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='审计日志表';

-- ========================================
-- 查看所有表
-- ========================================
SHOW TABLES;

-- ========================================
-- 查看表结构
-- ========================================
DESCRIBE classes;
DESCRIBE students;
DESCRIBE courses;
DESCRIBE scores;
DESCRIBE audit_log;

-- ========================================
-- 查看外键约束
-- ========================================
SELECT
    CONSTRAINT_NAME,
    TABLE_NAME,
    COLUMN_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'school_db'
AND REFERENCED_TABLE_NAME IS NOT NULL;

-- ========================================
-- 查看索引信息
-- ========================================
SHOW INDEX FROM students;
SHOW INDEX FROM scores;
