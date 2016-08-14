FROM fpco/stack-build:lts-6

WORKDIR /opt

RUN git clone --recursive https://github.com/ucsd-progsys/liquidhaskell.git
WORKDIR /opt/liquidhaskell

# "develop" branch
ENV LIQUID_SHA 4a489c9
RUN git checkout ${LIQUID_SHA} && \
    git submodule update --init --recursive && \
    stack install --local-bin-path=/usr/local/bin \
          liquiddesugar liquid-fixpoint prover liquidhaskell

WORKDIR /root
ADD . verified-instances
WORKDIR /root/verified-instances

RUN make all
