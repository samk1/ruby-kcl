#!/bin/zsh

>&2 echo "starting sub process"

rails runner ./sample_kcl.rb
