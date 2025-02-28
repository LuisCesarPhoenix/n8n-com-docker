ARG NODE_VERSION=20
# Define uma variável de argumento chamada NODE_VERSION, que será usada para especificar a versão do Node.js a ser usada.

# 1. Use uma etapa do construtor para baixar várias dependências
FROM node:${NODE_VERSION}-alpine as builder
# Usa uma imagem do Node.js baseada no Alpine Linux (uma distribuição leve) e atribui o nome "builder" a essa etapa.

# Instala fontes básicas no sistema
RUN	\
    apk --no-cache add --virtual fonts msttcorefonts-installer fontconfig && \
    update-ms-fonts && \
    fc-cache -f && \
    apk del fonts && \
    find  /usr/share/fonts/truetype/msttcorefonts/ -type l -exec unlink {} \;
# - Instala pacotes necessários para fontes (msttcorefonts-installer e fontconfig).
# - Atualiza as fontes do sistema.
# - Limpa os pacotes temporários para reduzir o tamanho da imagem.
# - Remove links simbólicos desnecessários de fontes.


# Instala Git e outras dependências do sistema operacional
RUN apk add --update git openssh graphicsmagick tini tzdata ca-certificates libc6-compat jq
# - `git` e `openssh`: necessários para gerenciar repositórios.
# - `graphicsmagick`: biblioteca para manipulação de imagens.
# - `tini`: gerenciador de processos para lidar com sinais do Docker.
# - `tzdata`: banco de dados de fusos horários.
# - `ca-certificates`: adiciona certificados SSL para conexões seguras.
# - `libc6-compat`: adiciona compatibilidade com algumas aplicações que requerem glibc.
# - `jq`: ferramenta para processar JSON na linha de comando.

# Atualiza o npm e instala dependências globais
COPY .npmrc /usr/local/etc/npmrc
RUN npm install -g npm@9.9.2 corepack@0.31 full-icu@1.5.0
# - Atualiza o npm para a versão 9.9.2.
# - Instala `corepack`, que permite gerenciar versões de pacotes como Yarn e PNPM.
# - Instala `full-icu`, que adiciona suporte total a internacionalização no Node.js.

# Ativa o corepack e prepara o ambiente para uso do pnpm
WORKDIR /tmp
COPY package.json ./
RUN corepack enable && corepack prepare --activate
# - Define `/tmp` como diretório de trabalho temporário.
# - Copia `package.json` para `/tmp` (provavelmente para que dependências possam ser instaladas posteriormente).
# - Ativa o `corepack` para gerenciar pacotes globalmente.

# Remove arquivos desnecessários para reduzir o tamanho da imagem final
RUN	rm -rf /lib/apk/db /var/cache/apk/ /tmp/* /root/.npm /root/.cache/node /opt/yarn*
# - Exclui caches e arquivos temporários para manter a imagem mais leve.

# 2. Comece com uma nova imagem limpa e copie os arquivos adicionados em uma única camada
FROM node:${NODE_VERSION}-alpine
# Inicia uma nova imagem limpa do Node.js baseada no Alpine Linux.

COPY --from=builder / /
# Copia todos os arquivos da fase "builder" para a nova imagem.

# Exclua esta pasta para tornar a imagem base compatível com versões anteriores, permitindo a construção de imagens de versões mais antigas.
# Remove cache do V8 para compatibilidade com versões antigas do Node.js
RUN rm -rf /tmp/v8-compile-cache*

WORKDIR /home/node
# Define o diretório de trabalho como `/home/node`, onde a aplicação será executada.

ENV NODE_ICU_DATA /usr/local/lib/node_modules/full-icu
# Define uma variável de ambiente para indicar o caminho do suporte a internacionalização no Node.js.

EXPOSE 5678/tcp
# Expõe a porta 5678 para permitir a comunicação externa com o container.