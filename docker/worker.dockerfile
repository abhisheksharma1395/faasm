ARG FAASM_VERSION
ARG FAASM_SGX_PARENT_SUFFIX
FROM faasm/base${FAASM_SGX_PARENT_SUFFIX}:${FAASM_VERSION}

# Build the worker binary
WORKDIR /build/faasm
RUN cd /build/faasm \
    && cmake --build . --target codegen_shared_obj \
    && cmake --build . --target codegen_func \
    && cmake --build . --target pool_runner

# Install hoststats
RUN pip3 install hoststats==0.1.0

# Set up entrypoint (for cgroups, namespaces etc.)
COPY bin/entrypoint_codegen.sh /entrypoint_codegen.sh
COPY bin/entrypoint_worker.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Create user with dummy uid required by Python
RUN groupadd -g 1000 faasm
RUN useradd -u 1000 -g 1000 faasm

ENTRYPOINT ["/entrypoint.sh"]
CMD "/build/faasm/bin/pool_runner"

