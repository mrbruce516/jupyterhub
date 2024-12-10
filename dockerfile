FROM nvidia/cuda:11.8.0-cudnn8-devel-ubuntu22.04

# 安装必要的系统包
RUN apt-get update && \
    apt-get install -y wget curl python3 python3-pip && \
    apt-get clean

# 安装 Miniconda
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/Miniconda3-latest-Linux-x86_64.sh && \
    bash /tmp/Miniconda3-latest-Linux-x86_64.sh -b -p /opt/conda && \
    rm /tmp/Miniconda3-latest-Linux-x86_64.sh

# 设置环境变量
ENV PATH /opt/conda/bin:$PATH

# 创建一个新的环境并安装JupyterLab和科学计算库
RUN conda install -y python=3.8 jupyterlab

# 安装JupyterHub和NativeAuthenticator
RUN pip install jupyterhub notebook ipywidgets \
    jupyterhub-nativeauthenticator jupyterlab-language-pack-zh-CN jupyter_contrib_nbextensions \
    argparse torch==2.0.0 torchvision==0.15.1 torchaudio==2.0.1 numpy pandas scikit-learn matplotlib typing functoolsplus scipy
RUN pip install sympy mamba_ssm

# 安装代理
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash -  && \
    apt install -y nodejs &&\
    npm install -g configurable-http-proxy

# 创建用户脚本
RUN useradd -m -s /bin/bash admin && echo "admin:admin" | chpasswd

# 复制 JupyterHub 配置文件
COPY jupyterhub_config.py /srv/jupyterhub/jupyterhub_config.py

CMD ["jupyterhub", "-f", "/srv/jupyterhub/jupyterhub_config.py"]
