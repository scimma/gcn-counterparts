## GCN Counterparts

This repository contains a makefile and a script for scraping GCN LVC counterparts
from the GCN Counterpart table web page [https://gcn.gsfc.nasa.gov/counterpart_tbl.html](https://gcn.gsfc.nasa.gov/counterpart_tbl.html) into files and uploading the files/counterparts to a HOP topic.

### Usage:

To scrape the GCN LVC counterparts, run ``make``.

To publish the GCN LVC counterparts to the topic defined in the makefile, ``Makefile``, run ``make publish``.

In order to publish, the ``hop`` command must be in your path and it must have credentials configured that have permission to publish to the topic configured in the makefile.

