"""
学校管理系统 - Python + MySQL 示例程序
说明：生产级别的数据库操作示例，演示完整的CRUD功能
对应讲义：重点讲义四 - Python操作MySQL数据库

功能模块：
1. 数据库连接管理
2. 学生信息管理（CRUD）
3. 班级信息管理
4. 课程信息管理
5. 成绩信息管理
6. 统计报表
7. 数据导出导入
"""

import sys
import json
from datetime import datetime
from typing import List, Dict, Any, Optional

# 导入自定义模块
from config import DB_CONFIG, APP_CONFIG, MESSAGES, TABLES
from database_utils import (
    get_connection,
    execute_sql,
    batch_insert,
    batch_update,
    paginate_query,
    transaction,
    QueryBuilder,
    format_table,
    export_to_csv,
    import_from_csv,
    backup_table,
    restore_table,
    get_table_info,
    DatabaseError
)


class SchoolManagementSystem:
    """学校管理系统主类"""

    def __init__(self):
        """初始化系统"""
        self.app_name = APP_CONFIG['app_name']
        self.version = APP_CONFIG['version']
        self.connected = False

    def connect(self) -> bool:
        """
        连接数据库

        Returns:
            是否连接成功
        """
        try:
            with get_connection() as conn:
                self.connected = True
                print(f"✓ {self.app_name} v{self.version} 启动成功")
                print(f"✓ 数据库连接成功（{DB_CONFIG['host']}:{DB_CONFIG['port']}/{DB_CONFIG['database']}）")
                return True
        except DatabaseError as e:
            print(f"✗ 数据库连接失败: {e}")
            return False

    # ========================================
    # 学生信息管理模块
    # ========================================

    def add_student(self, name: str, age: Optional[int] = None,
                   gender: Optional[str] = None, class_id: Optional[int] = None,
                   phone: Optional[str] = None, email: Optional[str] = None) -> int:
        """
        添加学生信息

        Args:
            name: 姓名
            age: 年龄
            gender: 性别
            class_id: 班级ID
            phone: 电话
            email: 邮箱

        Returns:
            学生ID
        """
        sql = """
        INSERT INTO students (name, age, gender, class_id, phone, email)
        VALUES (%s, %s, %s, %s, %s, %s)
        """
        params = (name, age, gender, class_id, phone, email)

        student_id = execute_sql(sql, params, fetch='none', autocommit=True)
        print(f"✓ 学生 {name} 添加成功，ID: {student_id}")
        return student_id

    def get_student(self, student_id: int) -> Optional[Dict[str, Any]]:
        """
        获取学生信息

        Args:
            student_id: 学生ID

        Returns:
            学生信息字典
        """
        sql = """
        SELECT
            s.*,
            c.name AS class_name,
            c.teacher AS class_teacher
        FROM students s
        LEFT JOIN classes c ON s.class_id = c.id
        WHERE s.id = %s
        """
        result = execute_sql(sql, (student_id,), fetch='one')

        if result:
            print(f"✓ 找到学生: {result['name']}")
        else:
            print(f"✗ 学生ID {student_id} 不存在")

        return result

    def get_students(self, page: int = 1, page_size: int = 10,
                    class_id: Optional[int] = None,
                    gender: Optional[str] = None,
                    min_age: Optional[int] = None,
                    max_age: Optional[int] = None) -> Tuple[List[Dict], int]:
        """
        获取学生列表（支持分页和过滤）

        Args:
            page: 页码
            page_size: 每页数量
            class_id: 班级ID（过滤）
            gender: 性别（过滤）
            min_age: 最小年龄（过滤）
            max_age: 最大年龄（过滤）

        Returns:
            (学生列表, 总记录数)
        """
        query = (QueryBuilder('students')
                 .select('s.*, c.name AS class_name, c.teacher AS class_teacher')
                 .join('classes c', 's.class_id = c.id'))

        if class_id:
            query = query.where('s.class_id = %s', class_id)

        if gender:
            query = query.where('s.gender = %s', gender)

        if min_age:
            query = query.where('s.age >= %s', min_age)

        if max_age:
            query = query.where('s.age <= %s', max_age)

        query = query.order_by('s.id')

        # 分页查询
        sql = query.build()
        params = query.get_params()

        results, total = paginate_query(sql, params, page, page_size)

        print(f"\n=== 学生列表 (第 {page} 页，共 {total} 条记录) ===")
        if results:
            print(format_table(results))
        else:
            print("无数据")

        return results, total

    def update_student(self, student_id: int, **kwargs) -> bool:
        """
        更新学生信息

        Args:
            student_id: 学生ID
            **kwargs: 更新的字段

        Returns:
            是否成功
        """
        if not kwargs:
            print("✗ 没有要更新的字段")
            return False

        result = batch_update('students', kwargs, {'id': student_id})

        if result > 0:
            print(f"✓ 学生ID {student_id} 更新成功")
            return True
        else:
            print(f"✗ 学生ID {student_id} 更新失败或不存在")
            return False

    def delete_student(self, student_id: int) -> bool:
        """
        删除学生信息

        Args:
            student_id: 学生ID

        Returns:
            是否成功
        """
        # 先查询确认
        student = self.get_student(student_id)
        if not student:
            return False

        # 确认删除
        confirm = input(f"确认删除学生 {student['name']}？(y/n): ")
        if confirm.lower() != 'y':
            print("已取消删除")
            return False

        sql = "DELETE FROM students WHERE id = %s"
        result = execute_sql(sql, (student_id,), fetch='none', autocommit=True)

        if result > 0:
            print(f"✓ 学生ID {student_id} 已删除")
            return True
        else:
            print(f"✗ 删除失败")
            return False

    def batch_add_students(self, students_list: List[Dict[str, Any]]) -> int:
        """
        批量添加学生

        Args:
            students_list: 学生信息列表

        Returns:
            添加的数量
        """
        return batch_insert('students', students_list)

    # ========================================
    # 成绩管理模块
    # ========================================

    def add_score(self, student_id: int, course_id: int,
                  score: float, exam_date: Optional[str] = None,
                  comment: Optional[str] = None) -> int:
        """
        添加成绩

        Args:
            student_id: 学生ID
            course_id: 课程ID
            score: 成绩
            exam_date: 考试日期
            comment: 评语

        Returns:
            成绩ID
        """
        if not exam_date:
            exam_date = datetime.now().strftime('%Y-%m-%d')

        sql = """
        INSERT INTO scores (student_id, course_id, score, exam_date, comment)
        VALUES (%s, %s, %s, %s, %s)
        """
        params = (student_id, course_id, score, exam_date, comment)

        score_id = execute_sql(sql, params, fetch='none', autocommit=True)
        print(f"✓ 成绩添加成功，ID: {score_id}")
        return score_id

    def get_student_scores(self, student_id: int) -> List[Dict[str, Any]]:
        """
        获取学生的所有成绩

        Args:
            student_id: 学生ID

        Returns:
            成绩列表
        """
        sql = """
        SELECT
            sc.id,
            co.name AS course_name,
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
        JOIN courses co ON sc.course_id = co.id
        WHERE sc.student_id = %s
        ORDER BY sc.exam_date DESC
        """
        results = execute_sql(sql, (student_id,), fetch='all')

        if results:
            print(f"\n=== 学生成绩列表 ===")
            print(format_table(results))
        else:
            print("该学生暂无成绩记录")

        return results

    def get_course_ranking(self, course_id: int, top_n: int = 10) -> List[Dict[str, Any]]:
        """
        获取课程成绩排名

        Args:
            course_id: 课程ID
            top_n: 前N名

        Returns:
            排名列表
        """
        sql = """
        SELECT
            s.name AS student_name,
            c.name AS class_name,
            sc.score,
            DENSE_RANK() OVER (ORDER BY sc.score DESC) AS rank
        FROM scores sc
        JOIN students s ON sc.student_id = s.id
        JOIN classes c ON s.class_id = c.id
        WHERE sc.course_id = %s
        """
        query = f"SELECT * FROM ({sql}) AS ranked WHERE rank <= {top_n}"

        results = execute_sql(query, (course_id,), fetch='all')

        if results:
            print(f"\n=== 课程成绩排名（前{top_n}名） ===")
            print(format_table(results))

        return results

    # ========================================
    # 统计报表模块
    # ========================================

    def get_class_statistics(self) -> List[Dict[str, Any]]:
        """
        获取班级统计信息

        Returns:
            统计信息列表
        """
        sql = """
        SELECT
            c.id AS class_id,
            c.name AS class_name,
            c.teacher,
            COUNT(DISTINCT s.id) AS student_count,
            ROUND(AVG(s.age), 1) AS avg_age,
            ROUND(AVG(sc.score), 2) AS avg_score,
            MAX(sc.score) AS max_score,
            MIN(sc.score) AS min_score
        FROM classes c
        LEFT JOIN students s ON c.id = s.class_id
        LEFT JOIN scores sc ON s.id = sc.student_id
        GROUP BY c.id, c.name, c.teacher
        ORDER BY student_count DESC
        """
        results = execute_sql(sql, fetch='all')

        print("\n=== 班级统计信息 ===")
        print(format_table(results))

        return results

    def get_score_statistics(self) -> Dict[str, Any]:
        """
        获取成绩统计信息

        Returns:
            统计信息字典
        """
        sql = """
        SELECT
            COUNT(*) AS total_scores,
            ROUND(AVG(score), 2) AS avg_score,
            MAX(score) AS max_score,
            MIN(score) AS min_score,
            SUM(CASE WHEN score >= 90 THEN 1 ELSE 0 END) AS excellent_count,
            SUM(CASE WHEN score >= 80 AND score < 90 THEN 1 ELSE 0 END) AS good_count,
            SUM(CASE WHEN score >= 60 AND score < 80 THEN 1 ELSE 0 END) AS pass_count,
            SUM(CASE WHEN score < 60 THEN 1 ELSE 0 END) AS fail_count
        FROM scores
        """
        result = execute_sql(sql, fetch='one')

        print("\n=== 成绩统计信息 ===")
        print(f"总成绩记录数: {result['total_scores']}")
        print(f"平均分: {result['avg_score']}")
        print(f"最高分: {result['max_score']}")
        print(f"最低分: {result['min_score']}")
        print(f"优秀（>=90）: {result['excellent_count']}")
        print(f"良好（80-89）: {result['good_count']}")
        print(f"及格（60-79）: {result['pass_count']}")
        print(f"不及格（<60）: {result['fail_count']}")

        return result

    def get_monthly_report(self, year: int, month: int) -> List[Dict[str, Any]]:
        """
        获取月度报表

        Args:
            year: 年份
            month: 月份

        Returns:
            月度报表数据
        """
        sql = """
        SELECT
            sc.exam_date,
            c.name AS course_name,
            COUNT(DISTINCT sc.student_id) AS student_count,
            ROUND(AVG(sc.score), 2) AS avg_score,
            MAX(sc.score) AS max_score,
            MIN(sc.score) AS min_score
        FROM scores sc
        JOIN courses c ON sc.course_id = c.id
        WHERE YEAR(sc.exam_date) = %s
          AND MONTH(sc.exam_date) = %s
        GROUP BY sc.exam_date, c.id, c.name
        ORDER BY sc.exam_date, c.name
        """
        results = execute_sql(sql, (year, month), fetch='all')

        print(f"\n=== {year}年{month}月度报表 ===")
        if results:
            print(format_table(results))
        else:
            print("该月无考试记录")

        return results

    # ========================================
    # 数据管理模块
    # ========================================

    def export_students(self, filename: str = 'students_export.csv') -> bool:
        """
        导出学生数据

        Args:
            filename: 文件名

        Returns:
            是否成功
        """
        results = execute_sql("SELECT * FROM students", fetch='all')
        return export_to_csv(results, filename)

    def import_students(self, filename: str) -> int:
        """
        导入学生数据

        Args:
            filename: 文件名

        Returns:
            导入的数量
        """
        return import_from_csv('students', filename)

    def backup_data(self, table: str) -> bool:
        """
        备份数据表

        Args:
            table: 表名

        Returns:
            是否成功
        """
        return backup_table(table)

    def restore_data(self, backup_table: str) -> bool:
        """
        恢复数据表

        Args:
            backup_table: 备份表名

        Returns:
            是否成功
        """
        return restore_table(backup_table)

    def show_table_info(self, table: str):
        """
        显示表信息

        Args:
            table: 表名
        """
        info = get_table_info(table)

        print(f"\n=== 表信息: {table} ===")
        print(f"行数: {info['row_count']}")

        print("\n字段信息:")
        print(format_table(info['columns']))

        print("\n索引信息:")
        print(format_table(info['indexes']))


# ========================================
# 演示主函数
# ========================================

def demo_basic_operations():
    """演示基础CRUD操作"""
    print("\n" + "=" * 60)
    print("演示一：基础CRUD操作")
    print("=" * 60)

    sms = SchoolManagementSystem()
    sms.connect()

    try:
        # 1. 添加学生
        print("\n【1. 添加学生】")
        student_id = sms.add_student(
            name='演示学生',
            age=20,
            gender='男',
            class_id=1,
            phone='13999999999',
            email='demo@example.com'
        )

        # 2. 查询学生
        print("\n【2. 查询学生】")
        student = sms.get_student(student_id)

        # 3. 更新学生
        print("\n【3. 更新学生】")
        sms.update_student(student_id, age=21)

        # 4. 删除学生
        print("\n【4. 删除学生】")
        # sms.delete_student(student_id)

    except Exception as e:
        print(f"演示出错: {e}")


def demo_advanced_queries():
    """演示高级查询"""
    print("\n" + "=" * 60)
    print("演示二：高级查询")
    print("=" * 60)

    sms = SchoolManagementSystem()
    sms.connect()

    try:
        # 1. 分页查询
        print("\n【1. 分页查询】")
        sms.get_students(page=1, page_size=5)

        # 2. 条件查询
        print("\n【2. 条件查询：成年男生】")
        sms.get_students(page=1, page_size=10, gender='男', min_age=18)

        # 3. 添加成绩
        print("\n【3. 添加成绩】")
        # score_id = sms.add_score(1, 1, 95.5, '2026-03-19', '表现优秀')

        # 4. 查询学生成绩
        print("\n【4. 查询学生成绩】")
        sms.get_student_scores(1)

        # 5. 课程排名
        print("\n【5. 课程排名】")
        sms.get_course_ranking(1, top_n=5)

    except Exception as e:
        print(f"演示出错: {e}")


def demo_statistics():
    """演示统计报表"""
    print("\n" + "=" * 60)
    print("演示三：统计报表")
    print("=" * 60)

    sms = SchoolManagementSystem()
    sms.connect()

    try:
        # 1. 班级统计
        print("\n【1. 班级统计】")
        sms.get_class_statistics()

        # 2. 成绩统计
        print("\n【2. 成绩统计】")
        sms.get_score_statistics()

        # 3. 月度报表
        print("\n【3. 月度报表】")
        sms.get_monthly_report(2026, 1)

    except Exception as e:
        print(f"演示出错: {e}")


def demo_data_management():
    """演示数据管理"""
    print("\n" + "=" * 60)
    print("演示四：数据管理")
    print("=" * 60)

    sms = SchoolManagementSystem()
    sms.connect()

    try:
        # 1. 显示表信息
        print("\n【1. 显示表信息】")
        sms.show_table_info('students')

        # 2. 导出数据
        print("\n【2. 导出数据】")
        # sms.export_students('students_backup.csv')

        # 3. 备份表
        print("\n【3. 备份表】")
        # sms.backup_data('students')

    except Exception as e:
        print(f"演示出错: {e}")


def main():
    """主函数"""
    print("=" * 60)
    print(f"    {APP_CONFIG['app_name']} v{APP_CONFIG['version']}")
    print("    Python + MySQL 数据库操作演示")
    print("=" * 60)

    # 运行所有演示
    demo_basic_operations()
    demo_advanced_queries()
    demo_statistics()
    demo_data_management()

    print("\n" + "=" * 60)
    print("    所有演示完成！")
    print("=" * 60)


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\n\n程序已终止")
        sys.exit(0)
    except Exception as e:
        print(f"\n程序出错: {e}")
        sys.exit(1)

