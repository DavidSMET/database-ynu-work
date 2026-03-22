"""
数据库配置文件
说明：集中管理数据库连接配置和其他配置项
对应讲义：重点讲义四 - Python操作MySQL数据库
"""

# 数据库连接配置
DB_CONFIG = {
    'host': 'localhost',          # 数据库主机地址
    'port': 3306,                 # 数据库端口
    'user': 'root',               # 数据库用户名
    'password': 'your_password',  # 数据库密码（请修改为实际密码）
    'database': 'school_db',      # 数据库名称
    'charset': 'utf8mb4',         # 字符集
    'autocommit': False,           # 是否自动提交
    'cursorclass': None,          # 游标类型（None为默认元组游标）
}

# 应用配置
APP_CONFIG = {
    'app_name': '学校管理系统',
    'version': '1.0.0',
    'debug': True,                # 调试模式
    'log_level': 'INFO',          # 日志级别
}

# 分页配置
PAGINATION = {
    'default_page_size': 10,      # 默认每页显示数量
    'max_page_size': 100,         # 最大每页显示数量
}

# 文件上传配置
UPLOAD_CONFIG = {
    'max_size': 10 * 1024 * 1024,  # 最大文件大小：10MB
    'allowed_extensions': ['.jpg', '.png', '.pdf', '.docx'],
}

# 缓存配置
CACHE_CONFIG = {
    'enabled': True,
    'ttl': 300,                   # 缓存过期时间（秒）
}

# 日志配置
LOG_CONFIG = {
    'format': '%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    'date_format': '%Y-%m-%d %H:%M:%S',
    'file_path': 'app.log',
}

# 数据库连接池配置（需要安装DBUtils）
POOL_CONFIG = {
    'enabled': False,              # 是否启用连接池
    'maxconnections': 10,         # 最大连接数
    'mincached': 2,               # 最小缓存连接数
    'maxcached': 5,               # 最大缓存连接数
    'maxshared': 3,               # 最大共享连接数
    'blocking': True,             # 连接池满时是否阻塞
    'maxusage': None,             # 单个连接最大使用次数
    'setsession': None,           # 连接前的SQL命令
}

# API配置
API_CONFIG = {
    'base_url': 'http://localhost:8000',
    'timeout': 30,                # 请求超时时间（秒）
    'retry_times': 3,             # 重试次数
}

# 安全配置
SECURITY_CONFIG = {
    'password_min_length': 8,      # 密码最小长度
    'session_timeout': 3600,       # 会话超时时间（秒）
    'max_login_attempts': 5,      # 最大登录尝试次数
}

# 数据验证规则
VALIDATION_RULES = {
    'students': {
        'name': {
            'required': True,
            'min_length': 2,
            'max_length': 50,
        },
        'age': {
            'required': False,
            'min': 0,
            'max': 150,
            'type': int,
        },
        'gender': {
            'required': True,
            'allowed_values': ['男', '女', '其他'],
        },
        'phone': {
            'required': False,
            'pattern': r'^1[3-9]\d{9}$',
        },
        'email': {
            'required': False,
            'pattern': r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
        },
    },
}

# 消息提示
MESSAGES = {
    'success': {
        'insert': '添加成功',
        'update': '更新成功',
        'delete': '删除成功',
        'query': '查询成功',
    },
    'error': {
        'database': '数据库操作失败',
        'not_found': '记录不存在',
        'duplicate': '记录已存在',
        'validation': '数据验证失败',
        'permission': '权限不足',
    },
}

# 数据库表名映射
TABLES = {
    'classes': 'classes',
    'students': 'students',
    'courses': 'courses',
    'scores': 'scores',
    'audit_log': 'audit_log',
}

# 查询模板
SQL_TEMPLATES = {
    'select_by_id': 'SELECT * FROM {table} WHERE id = %s',
    'insert': 'INSERT INTO {table} ({columns}) VALUES ({values})',
    'update': 'UPDATE {table} SET {set_clause} WHERE id = %s',
    'delete': 'DELETE FROM {table} WHERE id = %s',
}
