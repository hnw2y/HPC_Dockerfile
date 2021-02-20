FROM ubuntu:focal

USER root

WORKDIR /root

RUN apt-get update && \      
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    build-essential \             
    cryptsetup-bin \  
    dnsutils \
    libgpgme-dev \                   
    libseccomp-dev \                                   
    pkg-config \                    
    git \                        
    golang \                       
    rsync \
    nfs-common \
    netbase \
    ssh \
    iproute2 \
    squashfs-tools \           
    uuid-dev \        
    kmod \
    openssh-server \ 
    rpcbind \
    openmpi-bin \
    gromacs-openmpi \                                     
    vim \
    slurm-wlm \
    slurm-client \  
    wget \
    && apt-get clean

#------------------------------------------------------
# SLURM
RUN echo "Set disable_coredump false" >> /etc/sudo.conf
COPY slurm.conf /etc/slurm-llnl/slurm.conf
RUN chmod 777 /var/spool

COPY munge.key /etc/mungue/
RUN chown munge /etc/munge/munge.key

#------------------------------------------------------
# installing singularity
RUN wget https://github.com/hpcng/singularity/releases/download/v3.6.3/singularity-3.6.3.tar.gz
RUN tar -xzf singularity-3.6.3.tar.gz
    
WORKDIR /root/singularity

RUN ./mconfig && \
    make -C ./builddir && \
    make -C ./builddir install

WORKDIR /

#------------------------------------------------------
#NFS directory
RUN mkdir /home/volumes
#------------------------------------------------------
#ldap


#------------------------------------------------------
#SSH
#copies startup script and sets permissions
COPY start_services.sh /usr/local/bin/start_services.sh
RUN chmod +x /usr/local/bin/start_services.sh

# adds user jovyan and switches to that user
RUN useradd -m jovyan

# Setup ssh directory
RUN mkdir /home/jovyan/.ssh
RUN chmod 700 /home/jovyan/.ssh

# Install public key into authorized_keys
COPY authorized_keys /home/jovyan/.ssh/.
RUN chmod 644 /home/jovyan/.ssh/authorized_keys

# Install private key in to .ssh
COPY id_rsa /home/jovyan/.ssh/.
RUN chmod 600 /home/jovyan/.ssh/id_rsa

# Install public key into .ssh
COPY id_rsa.pub /home/jovyan/.ssh/.
RUN chmod 644 /home/jovyan/.ssh/id_rsa.pub

# Make current host key auto-login via known_hosts
RUN echo -n "* " >> /home/jovyan/.ssh/known_hosts
RUN cat /etc/ssh/ssh_host_ecdsa_key.pub >> /home/jovyan/.ssh/known_hosts
RUN chmod 600 /home/jovyan/.ssh/known_hosts
RUN chown -R jovyan /home/jovyan/.ssh


CMD /usr/local/bin/start_services.sh


USER jovyan