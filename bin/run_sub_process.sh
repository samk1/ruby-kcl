#!/bin/bash

>&2 echo "starting sub process"

rails runner ./kcl_process.rb
