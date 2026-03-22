# 学校管理系统 - Python + MySQL 数据库案例

一个完整的Python + MySQL数据库学习案例，包含理论文档、SQL脚本和Python代码，适用于学习和实际应用开发。

## 📋 项目简介

本项目提供了一个完整的学校管理系统数据库案例，涵盖了从基础到高级的SQL知识，以及生产级别的Python数据库操作代码。

### 核心特性

- ✅ **完整的数据库设计**：包含班级、学生、课程、成绩等核心表
- ✅ **SQL脚本示例**：从基础CRUD到高级特性（视图、存储过程、触发器）
- ✅ **Python代码示例**：生产级别的数据库操作代码
- ✅ **详细文档**：5个重点讲义，涵盖SQL和Python的所有重要知识点
- ✅ **工具函数封装**：提供通用的数据库操作工具类

## 📁 项目结构

```
数据库案例/
├── 文档资料/                    # 理论文档
│   ├── 数据库案例大纲.txt         # 完整学习大纲
│   ├── 重点讲义一-SQL四大类语言详解.txt
│   ├── 重点讲义二-SELECT查询详解.txt
│   ├── 重点讲义三-数据库设计与外键关系.txt
│   ├── 重点讲义四-Python操作MySQL数据库.txt
│   └── 重点讲义五-SQL高级特性详解.txt
│
├── SQL脚本/                      # SQL脚本文件
│   ├── 01_创建数据库.sql         # 创建数据库
│   ├── 02_创建数据表.sql         # 创建数据表（含外键和索引）
│   ├── 03_数据操作.sql           # CRUD操作和查询示例
│   └── 04_高级特性.sql           # 索引、视图、存储过程、触发器
│
└── python代码/                   # Python代码文件
    ├── config.py                 # 配置文件
    ├── database_utils.py         # 数据库工具类
    ├── database_demo.py          # 主程序
    └── requirements.txt         # 依赖包清单
```

## 🚀 快速开始

### 1. 环境准备

**安装MySQL数据库**
- 下载并安装MySQL Community Server：https://dev.mysql.com/downloads/
- 安装完成后启动MySQL服务

**安装Python依赖**
```bash
pip install -r requirements.txt
```

**配置数据库连接**
编辑 `python代码/config.py` 文件，修改数据库密码：
```python
DB_CONFIG = {
    'host': 'localhost',
    'port': 3306,
    'user': 'root',
    'password': 'your_password',  # 修改为你的密码
    'database': 'school_db',
    'charset': 'utf8mb4'
}
```

### 2. 初始化数据库

按照以下顺序执行SQL脚本：

```bash
# 方式1：命令行执行
mysql -u root -p < SQL脚本/01_创建数据库.sql
mysql -u root -p < SQL脚本/02_创建数据表.sql
mysql -u root -p < SQL脚本/03_数据操作.sql
mysql -u root -p < SQL脚本/04_高级特性.sql

# 方式2：MySQL客户端中执行
# 打开MySQL客户端
mysql -u root -p

# 在MySQL客户端中执行
source SQL脚本/01_创建数据库.sql;
source SQL脚本/02_创建数据表.sql;
source SQL脚本/03_数据操作.sql;
source SQL脚本/04_高级特性.sql;
```

### 3. 运行Python程序

```bash
cd python代码
python database_demo.py
```

## 📚 学习路径

### 阶段一：理论准备（30分钟）

1. 阅读 `数据库案例大纲.txt`
2. 学习 `重点讲义一-SQL四大类语言详解.txt`
3. 学习 `重点讲义三-数据库设计与外键关系.txt`

### 阶段二：SQL实践（1小时）

1. 执行 `01_创建数据库.sql`
2. 执行 `02_创建数据表.sql`，理解表设计和外键关系
3. 执行 `03_数据操作.sql`，实践CRUD操作
4. 执行 `04_高级特性.sql`，学习高级特性

### 阶段三：Python实践（1.5小时）

1. 学习 `重点讲义四-Python操作MySQL数据库.txt`
2. 运行 `database_demo.py`，观察输出结果
3. 修改代码进行实验，添加新功能

### 阶段四：深入学习（2小时）

1. 学习 `重点讲义二-SELECT查询详解.txt`
2. 学习 `重点讲义五-SQL高级特性详解.txt`
3. 实践优化和高级查询

## 📖 文档说明

### 重点讲义一：SQL四大类语言详解

- **DDL**：CREATE、ALTER、DROP、RENAME
- **DML**：INSERT、UPDATE、DELETE
- **DQL**：SELECT及各种查询
- **DCL**：GRANT、REVOKE、DENY
- **TCL**：COMMIT、ROLLBACK、SAVEPOINT

### 重点讲义二：SELECT查询详解

- 基础查询、条件查询
- 模糊查询、排序、分页
- 聚合函数、分组统计
- 连接查询、子查询、UNION
- 窗口函数、CTE

### 重点讲义三：数据库设计与外键关系

- 关系型数据库基本概念
- 三大范式（1NF、2NF、3NF）
- 完整的表结构设计
- 外键约束详解
- 索引设计原则

### 重点讲义四：Python操作MySQL数据库

- pymysql库使用
- 数据库连接管理
- CRUD操作详解
- 参数化查询（SQL注入防护）
- 事务管理、异常处理
- 工具函数封装

### 重点讲义五：SQL高级特性详解

- 索引：创建、查看、删除、优化
- 视图：创建、使用、更新
- 存储过程：参数、变量、流程控制
- 触发器：INSERT/UPDATE/DELETE
- 事务：ACID特性、隔离级别
- 窗口函数：排名、聚合、偏移

## 💡 代码示例

### SQL示例

```sql
-- 查询学生及其班级信息
SELECT
    s.name AS student_name,
    c.name AS class_name,
    c.teacher
FROM students s
JOIN classes c ON s.class_id = c.id
WHERE s.age > 18
ORDER BY s.id;
```

### Python示例

```python
from database_utils import execute_sql, QueryBuilder

# 简单查询
results = execute_sql("SELECT * FROM students WHERE age > %s", (18,), fetch='all')

# 使用查询构建器
query = (QueryBuilder('students')
         .select('name, age')
         .where('age > %s', 18)
         .order_by('age', 'DESC')
         .limit(10))

results = query.execute(fetch='all')
```

## 🎯 核心功能

### 学生管理

- 添加学生信息
- 查询学生列表（支持分页和过滤）
- 更新学生信息
- 删除学生信息
- 批量导入/导出

### 成绩管理

- 添加成绩记录
- 查询学生成绩
- 课程成绩排名
- 成绩统计分析

### 统计报表

- 班级统计
- 成绩统计
- 月度报表

### 数据管理

- 表信息查看
- 数据备份/恢复
- CSV导入/导出

## 🔧 工具函数

### DatabaseUtils类提供的主要功能：

- `execute_sql()` - 执行SQL语句
- `batch_insert()` - 批量插入
- `batch_update()` - 批量更新
- `paginate_query()` - 分页查询
- `transaction()` - 事务管理
- `QueryBuilder` - SQL查询构建器
- `format_table()` - 表格格式化输出
- `export_to_csv()` - 导出CSV
- `import_from_csv()` - 导入CSV
- `backup_table()` - 备份表
- `restore_table()` - 恢复表
- `analyze_query_performance()` - 分析查询性能

## 📊 数据库设计

### 表关系

```
classes (班级表)
    ↓ 1对多
students (学生表)
    ↓ 1对多
scores (成绩表)
    ↑ 多对1
courses (课程表)
```

### 核心表

1. **classes**：班级信息表
   - id, name, teacher, room, student_count

2. **students**：学生信息表
   - id, name, age, gender, class_id, phone, email

3. **courses**：课程信息表
   - id, name, credit, teacher, description

4. **scores**：成绩信息表
   - id, student_id, course_id, score, exam_date

5. **audit_log**：审计日志表
   - id, table_name, action, record_id, old_data, new_data

## 🛠️ 最佳实践

### SQL优化

1. 只查询需要的列
2. 使用索引列作为查询条件
3. 避免在索引列上使用函数
4. 使用EXPLAIN分析查询性能
5. 合理使用JOIN和子查询

### Python最佳实践

1. 使用参数化查询（防止SQL注入）
2. 使用上下文管理器管理连接
3. 正确处理异常
4. 使用连接池优化性能
5. 批量操作使用executemany

## 📝 注意事项

### 安全注意事项

⚠️ **重要**：不要在代码中硬编码数据库密码！
- 使用环境变量或配置文件
- 配置文件不要提交到版本控制

### 性能注意事项

- 大数据量操作使用分页
- 复杂查询考虑使用索引
- 批量操作优于循环操作
- 定期维护数据库索引

## 🔗 相关资源

### MySQL官方文档
- https://dev.mysql.com/doc/

### Python pymysql文档
- https://pymysql.readthedocs.io/

### SQL教程
- https://www.w3schools.com/sql/

## 📄 许可证

本项目仅供学习和参考使用。

## 👥 贡献

欢迎提出建议和改进！

## 📞 联系方式

如有问题或建议，请通过以下方式联系：
- 提交Issue
- 发送邮件

---

**祝学习愉快！**
