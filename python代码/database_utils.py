"""
数据库工具类
说明：提供数据库操作的通用工具函数和装饰器
对应讲义：重点讲义四 - Python操作MySQL数据库
"""

import pymysql
import json
import logging
from functools import wraps
from datetime import datetime
from typing import List, Dict, Any, Optional, Tuple
from contextlib import contextmanager
import traceback

# 导入配置
from config import DB_CONFIG, LOG_CONFIG

# 配置日志
logging.basicConfig(
    level=getattr(logging, LOG_CONFIG['log_level']),
    format=LOG_CONFIG['format'],
    datefmt=LOG_CONFIG['date_format']
)
logger = logging.getLogger(__name__)


class DatabaseError(Exception):
    """数据库错误基类"""
    pass


class ConnectionError(DatabaseError):
    """连接错误"""
    pass


class QueryError(DatabaseError):
    """查询错误"""
    pass


def handle_database_error(func):
    """数据库操作错误处理装饰器"""
    @wraps(func)
    def wrapper(*args, **kwargs):
        try:
            return func(*args, **kwargs)
        except pymysql.MySQLError as e:
            logger.error(f"MySQL错误: {e}")
            logger.error(traceback.format_exc())
            raise QueryError(f"数据库操作失败: {e}")
        except Exception as e:
            logger.error(f"未知错误: {e}")
            logger.error(traceback.format_exc())
            raise DatabaseError(f"系统错误: {e}")
    return wrapper


@contextmanager
def get_connection():
    """
    获取数据库连接的上下文管理器
    使用示例：
        with get_connection() as conn:
            with conn.cursor() as cursor:
                cursor.execute("SELECT * FROM students")
                results = cursor.fetchall()
    """
    conn = None
    try:
        conn = pymysql.connect(**DB_CONFIG)
        logger.info("数据库连接成功")
        yield conn
    except pymysql.MySQLError as e:
        logger.error(f"数据库连接失败: {e}")
        raise ConnectionError(f"无法连接到数据库: {e}")
    finally:
        if conn:
            conn.close()
            logger.info("数据库连接已关闭")


def execute_sql(
    sql: str,
    params: Optional[Tuple] = None,
    fetch: str = 'all',
    autocommit: bool = False
) -> Any:
    """
    执行SQL语句

    Args:
        sql: SQL语句
        params: 参数元组
        fetch: 返回类型（'all'/'one'/'none'）
        autocommit: 是否自动提交

    Returns:
        根据fetch参数返回查询结果或影响的行数
    """
    with get_connection() as conn:
        with conn.cursor(pymysql.cursors.DictCursor) as cursor:
            logger.debug(f"执行SQL: {sql}")
            logger.debug(f"参数: {params}")

            cursor.execute(sql, params or ())

            if autocommit:
                conn.commit()

            if fetch == 'all':
                results = cursor.fetchall()
                logger.debug(f"返回 {len(results)} 条记录")
                return results
            elif fetch == 'one':
                result = cursor.fetchone()
                logger.debug(f"返回1条记录")
                return result
            else:
                conn.commit()
                affected_rows = cursor.rowcount
                logger.debug(f"影响 {affected_rows} 行")
                return affected_rows


def batch_insert(
    table: str,
    data_list: List[Dict[str, Any]],
    on_duplicate: str = None
) -> int:
    """
    批量插入数据

    Args:
        table: 表名
        data_list: 数据字典列表
        on_duplicate: 重复处理方式（'ignore'/'update'）

    Returns:
        插入的行数
    """
    if not data_list:
        return 0

    columns = data_list[0].keys()
    columns_str = ', '.join(columns)
    placeholders = ', '.join(['%s'] * len(columns))

    sql = f"""
        INSERT {on_duplicate or ''}
        INTO {table} ({columns_str})
        VALUES ({placeholders})
    """

    params_list = [tuple(item.values()) for item in data_list]

    with get_connection() as conn:
        with conn.cursor() as cursor:
            affected_rows = cursor.executemany(sql, params_list)
            conn.commit()
            logger.info(f"批量插入到 {table}，共 {affected_rows} 条记录")
            return affected_rows


def batch_update(
    table: str,
    updates: Dict[str, Any],
    conditions: Dict[str, Any]
) -> int:
    """
    批量更新数据

    Args:
        table: 表名
        updates: 更新字段字典
        conditions: 条件字段字典

    Returns:
        影响的行数
    """
    if not updates or not conditions:
        return 0

    set_clause = ', '.join([f"{k} = %s" for k in updates.keys()])
    where_clause = ' AND '.join([f"{k} = %s" for k in conditions.keys()])
    params = tuple(updates.values()) + tuple(conditions.values())

    sql = f"UPDATE {table} SET {set_clause} WHERE {where_clause}"

    return execute_sql(sql, params, fetch='none', autocommit=True)


def paginate_query(
    sql: str,
    params: Optional[Tuple] = None,
    page: int = 1,
    page_size: int = 10
) -> Tuple[List[Dict], int]:
    """
    分页查询

    Args:
        sql: SQL语句
        params: 参数元组
        page: 页码（从1开始）
        page_size: 每页数量

    Returns:
        (结果列表, 总记录数)
    """
    offset = (page - 1) * page_size

    # 查询总数
    count_sql = f"SELECT COUNT(*) AS total FROM ({sql}) AS temp"
    count_result = execute_sql(count_sql, params, fetch='one')
    total = count_result['total'] if count_result else 0

    # 查询分页数据
    paginated_sql = f"{sql} LIMIT {page_size} OFFSET {offset}"
    results = execute_sql(paginated_sql, params, fetch='all')

    return results, total


def transaction(operations: List[Dict[str, Any]]) -> bool:
    """
    执行事务

    Args:
        operations: 操作列表，每个操作包含'sql'和'params'字段

    Returns:
        是否成功
    """
    with get_connection() as conn:
        try:
            conn.begin()
            with conn.cursor() as cursor:
                for op in operations:
                    cursor.execute(op['sql'], op.get('params', ()))
                    logger.debug(f"事务操作: {op['sql']}")

            conn.commit()
            logger.info(f"事务执行成功，共 {len(operations)} 个操作")
            return True

        except Exception as e:
            conn.rollback()
            logger.error(f"事务执行失败，已回滚: {e}")
            return False


class QueryBuilder:
    """SQL查询构建器"""

    def __init__(self, table: str):
        self.table = table
        self._select = '*'
        self._where = []
        self._join = []
        self._group_by = []
        self._having = []
        self._order_by = []
        self._limit = None
        self._offset = None
        self._params = []

    def select(self, columns: str) -> 'QueryBuilder':
        """设置查询列"""
        self._select = columns
        return self

    def where(self, condition: str, *args) -> 'QueryBuilder':
        """添加WHERE条件"""
        self._where.append(condition)
        self._params.extend(args)
        return self

    def join(
        self,
        table: str,
        on: str,
        join_type: str = 'INNER'
    ) -> 'QueryBuilder':
        """添加JOIN"""
        self._join.append(f"{join_type} JOIN {table} ON {on}")
        return self

    def group_by(self, column: str) -> 'QueryBuilder':
        """添加GROUP BY"""
        self._group_by.append(column)
        return self

    def having(self, condition: str, *args) -> 'QueryBuilder':
        """添加HAVING"""
        self._having.append(condition)
        self._params.extend(args)
        return self

    def order_by(self, column: str, direction: str = 'ASC') -> 'QueryBuilder':
        """添加ORDER BY"""
        self._order_by.append(f"{column} {direction}")
        return self

    def limit(self, limit: int) -> 'QueryBuilder':
        """设置LIMIT"""
        self._limit = limit
        return self

    def offset(self, offset: int) -> 'QueryBuilder':
        """设置OFFSET"""
        self._offset = offset
        return self

    def build(self) -> str:
        """构建SQL语句"""
        parts = [f"SELECT {self._select} FROM {self.table}"]

        if self._join:
            parts.extend(self._join)

        if self._where:
            parts.append("WHERE " + " AND ".join(self._where))

        if self._group_by:
            parts.append("GROUP BY " + ", ".join(self._group_by))

        if self._having:
            parts.append("HAVING " + " AND ".join(self._having))

        if self._order_by:
            parts.append("ORDER BY " + ", ".join(self._order_by))

        if self._limit is not None:
            parts.append(f"LIMIT {self._limit}")

        if self._offset is not None:
            parts.append(f"OFFSET {self._offset}")

        return " ".join(parts)

    def get_params(self) -> tuple:
        """获取参数"""
        return tuple(self._params)

    def execute(self, fetch: str = 'all') -> Any:
        """执行查询"""
        sql = self.build()
        return execute_sql(sql, self.get_params(), fetch=fetch)


def format_table(
    data: List[Dict[str, Any]],
    max_width: int = 100
) -> str:
    """
    格式化输出表格

    Args:
        data: 数据列表
        max_width: 最大宽度

    Returns:
        格式化的表格字符串
    """
    if not data:
        return "无数据"

    columns = list(data[0].keys())

    # 计算每列宽度
    widths = {col: len(str(col)) for col in columns}
    for row in data:
        for col in columns:
            value = str(row[col]) if row[col] is not None else 'NULL'
            width = min(len(value), max_width)
            if width > widths[col]:
                widths[col] = width

    # 构建表格
    lines = []

    # 表头
    header = " | ".join(col.ljust(widths[col]) for col in columns)
    lines.append(header)

    # 分隔线
    separator = "-+-".join("-" * widths[col] for col in columns)
    lines.append(separator)

    # 数据行
    for row in data:
        values = []
        for col in columns:
            value = str(row[col]) if row[col] is not None else 'NULL'
            value = value[:max_width] if len(value) > max_width else value
            values.append(value.ljust(widths[col]))
        line = " | ".join(values)
        lines.append(line)

    return "\n".join(lines)


def export_to_csv(
    data: List[Dict[str, Any]],
    filename: str,
    encoding: str = 'utf-8-sig'
) -> bool:
    """
    导出数据到CSV文件

    Args:
        data: 数据列表
        filename: 文件名
        encoding: 编码格式

    Returns:
        是否成功
    """
    try:
        import csv

        if not data:
            return False

        with open(filename, 'w', newline='', encoding=encoding) as f:
            writer = csv.DictWriter(f, fieldnames=data[0].keys())
            writer.writeheader()
            writer.writerows(data)

        logger.info(f"数据已导出到 {filename}")
        return True
    except Exception as e:
        logger.error(f"导出CSV失败: {e}")
        return False


def import_from_csv(
    table: str,
    filename: str,
    encoding: str = 'utf-8-sig'
) -> int:
    """
    从CSV文件导入数据

    Args:
        table: 表名
        filename: 文件名
        encoding: 编码格式

    Returns:
        导入的行数
    """
    try:
        import csv

        with open(filename, 'r', encoding=encoding) as f:
            reader = csv.DictReader(f)
            data_list = list(reader)

        return batch_insert(table, data_list)
    except Exception as e:
        logger.error(f"导入CSV失败: {e}")
        return 0


def backup_table(
    table: str,
    backup_table: str = None
) -> bool:
    """
    备份表

    Args:
        table: 表名
        backup_table: 备份表名（默认为table_backup）

    Returns:
        是否成功
    """
    if not backup_table:
        backup_table = f"{table}_backup_{datetime.now().strftime('%Y%m%d_%H%M%S')}"

    sql = f"CREATE TABLE {backup_table} AS SELECT * FROM {table}"
    try:
        execute_sql(sql, fetch='none', autocommit=True)
        logger.info(f"表 {table} 已备份到 {backup_table}")
        return True
    except Exception as e:
        logger.error(f"备份失败: {e}")
        return False


def restore_table(
    backup_table: str,
    target_table: str = None
) -> bool:
    """
    恢复表

    Args:
        backup_table: 备份表名
        target_table: 目标表名（默认为去掉备份后缀）

    Returns:
        是否成功
    """
    if not target_table:
        # 移除备份后缀
        parts = backup_table.rsplit('_backup_', 1)
        target_table = parts[0] if len(parts) > 1 else backup_table

    sql = f"DROP TABLE IF EXISTS {target_table}; RENAME TABLE {backup_table} TO {target_table}"
    try:
        execute_sql(sql, fetch='none', autocommit=True)
        logger.info(f"表已从 {backup_table} 恢复到 {target_table}")
        return True
    except Exception as e:
        logger.error(f"恢复失败: {e}")
        return False


def analyze_query_performance(sql: str, params: tuple = None) -> Dict[str, Any]:
    """
    分析查询性能

    Args:
        sql: SQL语句
        params: 参数

    Returns:
        性能分析结果
    """
    explain_sql = f"EXPLAIN {sql}"
    result = execute_sql(explain_sql, params, fetch='one')

    return {
        'type': result.get('type', ''),
        'key': result.get('key', ''),
        'rows': result.get('rows', 0),
        'extra': result.get('Extra', ''),
    }


def get_table_info(table: str) -> Dict[str, Any]:
    """
    获取表信息

    Args:
        table: 表名

    Returns:
        表信息字典
    """
    # 获取表结构
    columns = execute_sql(f"DESCRIBE {table}", fetch='all')

    # 获取索引信息
    indexes = execute_sql(f"SHOW INDEX FROM {table}", fetch='all')

    # 获取行数
    count_result = execute_sql(f"SELECT COUNT(*) AS count FROM {table}", fetch='one')
    row_count = count_result['count'] if count_result else 0

    return {
        'table_name': table,
        'row_count': row_count,
        'columns': columns,
        'indexes': indexes,
    }


if __name__ == '__main__':
    # 测试代码
    print("数据库工具类测试")
    print("=" * 50)

    # 测试连接
    try:
        with get_connection() as conn:
            print("✓ 数据库连接测试成功")
    except Exception as e:
        print(f"✗ 数据库连接测试失败: {e}")

    # 测试查询
    try:
        results = execute_sql("SELECT * FROM students LIMIT 5", fetch='all')
        print(f"✓ 查询测试成功，返回 {len(results)} 条记录")
        print(format_table(results))
    except Exception as e:
        print(f"✗ 查询测试失败: {e}")
