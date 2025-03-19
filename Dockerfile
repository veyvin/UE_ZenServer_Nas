# 使用稳定的 Ubuntu LTS 版本
FROM ubuntu:24.04

# 设置构建参数（保留可能需要的环境变量）
ARG CLANG_VERSION=17

# 安装基础运行时依赖（精简掉编译相关工具）
RUN apt update && apt install -y \
    ca-certificates \
    libc++-17-dev \
    libssl-dev \
    zlib1g-dev \
    && apt clean \
    && rm -rf /var/lib/apt/lists/*

# 创建非特权用户
RUN useradd -m -s /bin/bash zen \
    && echo "zen ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# 提前创建目标目录并设置权限
RUN mkdir -p /home/zen/main/bin \
    && chown -R zen:zen /home/zen/main

# 复制预编译文件（需确保本地文件与 Dockerfile 同目录）
COPY --chown=zen:zen zen zenserver /home/zen/main/bin/

# 切换到 zen 用户环境
USER zen
WORKDIR /home/zen/main

# 验证文件可执行性
RUN  chmod +x bin/zen bin/zenserver

# 配置运行时环境变量
ENV PATH="/home/zen/main/bin:${PATH}"

# 设置健康检查（根据实际服务特性调整）
HEALTHCHECK --interval=30s --timeout=3s \
    CMD curl -f http://localhost:8080/health || exit 1

# 设置容器入口点
ENTRYPOINT ["zenserver"]
CMD ["--config", "/home/zen/main/config.yaml"] 