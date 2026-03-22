-- ========================================
-- 数据库案例 - SQL脚本
-- 01_创建数据库.sql
-- 说明：创建数据库并配置字符集
-- 对应讲义：重点讲义三 - 数据库设计
-- ========================================

-- 创建数据库
-- 使用IF NOT EXISTS避免重复创建错误
-- DEFAULT CHARACTER SET：设置默认字符集为utf8mb4（支持中文和emoji）
-- DEFAULT COLLATE：设置默认排序规则为unicode_ci（不区分大小写）
CREATE DATABASE IF NOT EXISTS school_db
    DEFAULT CHARACTER SET utf8mb4
    DEFAULT COLLATE utf8mb4_unicode_ci;

-- 使用数据库
USE school_db;

-- 查看当前数据库（确认切换成功）
SELECT DATABASE() AS current_database;

-- 显示数据库信息
SHOW CREATE DATABASE school_db;

-- ========================================
-- 额外功能：删除数据库（谨慎使用）
-- ========================================
-- DROP DATABASE IF EXISTS school_db;
-- ⚠️ 警告：此命令会永久删除数据库及其所有数据！
