# 允许所有可以成功验证对 Hub 访问权限的用户
c.Authenticator.allow_all = True
c.Authenticator.allow_existing_users = True

# 设置管理员用户
c.Authenticator.admin_users = {'admin'}

# 允许 root 用户启动 JupyterLab
c.Spawner.args = ['--allow-root', '--NotebookApp.terminals_enabled=False']

# 设置单用户服务器的监听 IP 地址
c.Spawner.ip = '0.0.0.0'

# 设置默认启动 URL 为 JupyterLab
c.Spawner.default_url = '/lab'

# 设置单用户服务器的工作目录
c.Spawner.notebook_dir = '~'

# 设置启动命令为 JupyterLab
c.Spawner.cmd = ['/opt/conda/envs/py310/bin/jupyter-labhub']

# 允许创建系统用户
c.LocalAuthenticator.create_system_users = True

# 配置使用 NativeAuthenticator
c.JupyterHub.authenticator_class = 'nativeauthenticator.NativeAuthenticator'

# 配置用户的工作目录
c.LocalProcessSpawner.notebook_dir = '/home/{username}/notebooks'

# 导入所需模块
import os
import subprocess

# 定义 pre_spawn_hook 函数，用于在用户服务器启动之前创建用户目录
def create_user_directory(spawner):
    username = spawner.user.name
    user_home = f"/home/{username}"
    user_notebook_dir = os.path.join(user_home, "notebooks")

    # 检查用户是否存在
    try:
        subprocess.check_call(['id', username])
    except subprocess.CalledProcessError:
        # 用户不存在，创建用户
        subprocess.check_call(['useradd', '-m', username])

    # 创建用户的 notebook 目录
    if not os.path.exists(user_notebook_dir):
        os.makedirs(user_notebook_dir)
        subprocess.check_call(['chown', '-R', f'{username}:{username}', user_home])

# 配置使用 LocalProcessSpawner
c.JupyterHub.spawner_class = 'jupyterhub.spawner.LocalProcessSpawner'

# 配置 pre_spawn_hook
c.Spawner.pre_spawn_hook = create_user_directory

# 配置自定义模板路径
import nativeauthenticator
c.JupyterHub.template_paths = [f"{os.path.dirname(nativeauthenticator.__file__)}/templates/"]

# 配置服务，如 idle-culler
c.JupyterHub.services = [
    {
        'name': 'idle-culler',
        'command': ['/opt/conda/envs/py310/bin/python', '-m', 'jupyterhub_idle_culler', '--timeout=3600'],
        'admin': True  # 1.5.0 需要服务管理员权限
    }
]

