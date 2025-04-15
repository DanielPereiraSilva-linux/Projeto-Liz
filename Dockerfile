FROM ubuntu:22.04

# Instala pacotes essenciais
RUN apt-get update && apt-get install -y \
    bash curl sudo wget ttyd net-tools iputils-ping vim htop git passwd && \
    ln -sf /bin/bash /bin/rbash

# Define a senha do root
RUN echo "root:bTFmX5hdot3" | chpasswd

# Cria usuário visitante com shell bash (vamos trocar depois para rbash no terminal)
RUN useradd -m -s /bin/bash visitante && \
    echo 'PATH=/home/visitante/bin:$PATH' >> /home/visitante/.bashrc && \
    mkdir -p /home/visitante/bin /home/visitante/workdir

# Copia apenas os comandos permitidos
RUN for cmd in ls pwd whoami htop clear ping cat mkdir rm rmdir mv touch; do \
      ln -s /bin/$cmd /home/visitante/bin/$cmd || ln -s /usr/bin/$cmd /home/visitante/bin/$cmd; \
    done

# Corrige permissões
RUN chown -R visitante:visitante /home/visitante && \
    chmod 700 /home/visitante && \
    chmod 500 /home/visitante/bin && \
    chmod 755 /home/visitante/workdir

# Define hostname e prompt personalizado
RUN echo "projeto-liz" > /etc/hostname && \
    echo "127.0.0.1 projeto-liz" >> /etc/hosts && \
    echo 'export PS1="\[\033[0;32m\]visitante@projeto-liz:\w\$ \[\033[0m\]"' >> /home/visitante/.bashrc

USER visitante
WORKDIR /home/visitante

EXPOSE porta

# Inicia ttyd com bash e carrega rbash como subshell
CMD ["ttyd", "-p", "7681", "--base-path", "/", "bash", "-c", "rbash -l"]
