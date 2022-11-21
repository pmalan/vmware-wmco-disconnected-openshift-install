#!/bin/bash

dnf install -y dhcpd
dnf install -y dnsmasq
cp -r etc /etc 
systemctl enable --now dhcpd
systemctl enable --now dnsmasq