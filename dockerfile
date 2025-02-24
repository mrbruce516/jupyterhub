FROM nvidia/cuda:12.4.1-cudnn-devel-ubuntu22.04

# 安装必要的系统包
RUN apt-get update && \
    apt-get install -y wget curl && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 安装 Miniconda
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/Miniconda3-latest-Linux-x86_64.sh && \
    bash /tmp/Miniconda3-latest-Linux-x86_64.sh -b -p /opt/conda && \
    rm /tmp/Miniconda3-latest-Linux-x86_64.sh
ENV PATH="/opt/conda/bin:$PATH"
RUN /opt/conda/bin/conda init bash

# 创建 Conda 环境并安装依赖
RUN conda create -n py310 python=3.10 -y && \
    /opt/conda/envs/py310/bin/python -m pip install ipykernel \
    jupyterhub notebook ipywidgets \
    jupyterhub-nativeauthenticator jupyterlab-language-pack-zh-CN jupyter_contrib_nbextensions \
    argparse torch torchvision torchaudio \
    sympy mamba_ssm && \
    /opt/conda/envs/py310/bin/python -m pip cache purge && \
    /opt/conda/envs/py310/bin/python -m ipykernel install --user --name=python3.10 --display-name "Python 3.10" && \
    conda clean -afy

# 安装 Node.js 相关工具
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g configurable-http-proxy

# 创建用户
RUN useradd -m -s /bin/bash admin && echo "admin:admin" | chpasswd

# 复制配置文件
COPY jupyterhub_config.py /srv/jupyterhub/jupyterhub_config.py

CMD ["/opt/conda/envs/py310/bin/python", "-m", "jupyterhub", "-f", "/srv/jupyterhub/jupyterhub_config.py"]