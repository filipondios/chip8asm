# Usar una imagen base oficial de Ubuntu
FROM ubuntu:20.04

# Establecer variables de entorno para evitar la interacción durante
# la instalación de paquetes
ENV DEBIAN_FRONTEND=noninteractive

# Actualizar el repositorio de paquetes y luego instalar los 
# paquetes necesarios
RUN apt-get update && apt-get install -y \
    git \
    gcc \
    make \
    wget \
    build-essential \
    libasound2-dev \
    libx11-dev \
    libxrandr-dev \
    libxi-dev \
    libgl1-mesa-dev \
    libglu1-mesa-dev \
    libxcursor-dev \
    libxinerama-dev \
    libwayland-dev \
    libxkbcommon-dev \
    && apt-get clean

# Establecer el directorio de trabajo
WORKDIR /home/ubuntu

# Descargar, extraer, compilar e instalar NASM
RUN wget https://www.nasm.us/pub/nasm/releasebuilds/2.16.03/nasm-2.16.03.tar.gz \
    && tar xfv nasm-2.16.03.tar.gz \
    && cd nasm-2.16.03 \
    && ./configure \
    && make \
    && make install \
    && cd .. \
    && rm -rf nasm*

# Clonar, compilar e instalar raylib
RUN git clone --depth 1 https://github.com/raysan5/raylib.git raylib \
    && cd raylib/src \
    && make PLATFORM=PLATFORM_DESKTOP \
    && make install \
    && cd ../../ \
    && rm -rf raylib

# Clonar y compilar chip8asm
RUN git clone https://github.com/dpv927/chip8asm.git \
    && cd chip8asm/src \
    && make

# Establecer el directorio de trabajo como el directorio de inicio
WORKDIR /home/ubuntu/chip8asm/src

# Comando por defecto para mantener el contenedor en ejecución
CMD ["bash"]
