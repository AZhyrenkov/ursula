#!/usr/bin/with-contenv bash
if [ "$RUN_RSTUDIO" != "no" ]
  then
  exec /usr/lib/rstudio-server/bin/rserver
fi