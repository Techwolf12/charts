FROM pretix/standalone:stable
USER root
RUN pip3 install pretix-passbook pretix-countdown pretix-roomsharing pretix-regid
USER pretixuser
RUN cd /pretix/src && make production