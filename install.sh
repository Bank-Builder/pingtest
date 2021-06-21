#!/bin/bash
# Copyright (c) 2018, Andrew Turpin
# License MIT: https://opensource.org/licenses/MIT
sudo cp pingtest.sh /usr/bin/pingtest
sudo chmod +x /usr/bin/pingtest
pingtest --version
# Installation complete
# sudo rm /usr/bin/pingtest to uninstall